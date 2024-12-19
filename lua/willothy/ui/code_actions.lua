-- based on https://github.com/neovim/neovim/blob/v0.7.2/runtime/lua/vim/lsp/util.lua#L106-L124
--- Convert UTF index to `encoding` index.
--- Convenience wrapper around vim.str_byteindex
---Alternative to vim.str_byteindex that takes an encoding.
---@param line string line to be indexed
---@param index number UTF index
---@param encoding string utf-8|utf-16|utf-32|nil defaults to utf-16
---@return number byte (utf-8) index of `encoding` index `index` in `line`
local function _str_byteindex_enc(line, index, encoding)
  if not encoding then
    encoding = "utf-16"
  end
  if encoding == "utf-8" then
    if index then
      return index
    else
      return #line
    end
  elseif encoding == "utf-16" then
    return vim.str_byteindex(line, encoding, index, true)
  elseif encoding == "utf-32" then
    return vim.str_byteindex(line, encoding, index)
  else
    error("Invalid encoding: " .. vim.inspect(encoding))
  end
end

local function get_lines(bufnr)
  vim.fn.bufload(bufnr)
  return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

-- based on https://github.com/neovim/neovim/blob/v0.7.2/runtime/lua/vim/lsp/util.lua#L277-L298
---@private
--- Position is a https://microsoft.github.io/language-server-protocol/specifications/specification-current/#position
--- Returns a zero-indexed column, since set_lines() does the conversion to
---@param offset_encoding string utf-8|utf-16|utf-32
--- 1-indexed
local function get_line_byte_from_position(lines, position, offset_encoding)
  -- LSP's line and characters are 0-indexed
  -- Vim's line and columns are 1-indexed
  local col = position.character
  -- When on the first character, we can ignore the difference between byte and
  -- character
  if col > 0 then
    local line = lines[position.line + 1] or ""
    local ok, result
    ok, result = pcall(_str_byteindex_enc, line, col, offset_encoding)
    if ok then
      return result
    end
    return math.min(#line, col)
  end
  return col
end

local function get_eol(bufnr)
  local ff = vim.api.nvim_get_option_value("fileformat", { buf = bufnr })
  if ff == "dos" then
    return "\r\n"
  elseif ff == "unix" then
    return "\n"
  elseif ff == "mac" then
    return "\r"
  else
    error("invalid fileformat")
  end
end

-- based on https://github.com/neovim/neovim/blob/v0.7.2/runtime/lua/vim/lsp/util.lua#L336-L464
local function apply_text_edits(text_edits, lines, offset_encoding)
  -- Fix reversed range and indexing each text_edits
  local index = 0
  text_edits = vim.tbl_map(function(text_edit)
    index = index + 1
    text_edit._index = index

    if
      text_edit.range.start.line > text_edit.range["end"].line
      or text_edit.range.start.line == text_edit.range["end"].line
        and text_edit.range.start.character > text_edit.range["end"].character
    then
      local start = text_edit.range.start
      text_edit.range.start = text_edit.range["end"]
      text_edit.range["end"] = start
    end
    return text_edit
  end, text_edits)

  -- Sort text_edits
  table.sort(text_edits, function(a, b)
    if a.range.start.line ~= b.range.start.line then
      return a.range.start.line > b.range.start.line
    end
    if a.range.start.character ~= b.range.start.character then
      return a.range.start.character > b.range.start.character
    end
    if a._index ~= b._index then
      return a._index > b._index
    end
    return false
  end)

  -- Apply text edits.
  for _, text_edit in ipairs(text_edits) do
    -- Normalize line ending
    text_edit.newText, _ = string.gsub(text_edit.newText, "\r\n?", "\n")

    -- Convert from LSP style ranges to Neovim style ranges.
    local e = {
      start_row = text_edit.range.start.line,
      start_col = get_line_byte_from_position(
        lines,
        text_edit.range.start,
        offset_encoding
      ),
      end_row = text_edit.range["end"].line,
      end_col = get_line_byte_from_position(
        lines,
        text_edit.range["end"],
        offset_encoding
      ),
      text = vim.split(text_edit.newText, "\n"),
    }

    -- apply edits
    local before = (lines[e.start_row + 1] or ""):sub(1, e.start_col)
    local after = (lines[e.end_row + 1] or ""):sub(e.end_col + 1)
    for _ = e.start_row, e.end_row do
      table.remove(lines, e.start_row + 1)
    end
    for i, t in pairs(e.text) do
      if text_edit.insertTextFormat == 2 then
        local snippet = require("vim.lsp._snippet_grammar")
        local ok, parsed = pcall(snippet.parse, t)
        if ok then
          t = tostring(parsed)
        end
      end

      table.insert(lines, e.start_row + i, t)
    end
    lines[e.start_row + 1] = before .. lines[e.start_row + 1]
    lines[e.start_row + #e.text] = lines[e.start_row + #e.text] .. after
  end
end

local function diff_text_edits(text_edits, _bufnr, offset_encoding)
  local eol = get_eol(_bufnr)

  local lines = get_lines(_bufnr)
  local old_text = table.concat(lines, eol)
  apply_text_edits(text_edits, lines, offset_encoding)

  return vim.diff(old_text .. "\n", table.concat(lines, eol) .. "\n", {
    ctxlen = 3,
  })
end

-- based on https://github.com/neovim/neovim/blob/v0.7.2/runtime/lua/vim/lsp/util.lua#L492-L523
local function diff_text_document_edit(text_document_edit, offset_encoding)
  local text_document = text_document_edit.textDocument
  local _bufnr = vim.uri_to_bufnr(text_document.uri)

  return diff_text_edits(text_document_edit.edits, _bufnr, offset_encoding)
end

-- based on https://github.com/neovim/neovim/blob/v0.7.2/runtime/lua/vim/lsp/util.lua#L717-L756
local function diff_workspace_edit(workspace_edit, offset_encoding)
  local diff = ""
  if workspace_edit.documentChanges then
    for _, change in ipairs(workspace_edit.documentChanges) do
      -- imitate git diff
      if change.kind == "rename" then
        local old_path =
          vim.fn.fnamemodify(vim.uri_to_fname(change.oldUri), ":.")
        local new_path =
          vim.fn.fnamemodify(vim.uri_to_fname(change.newUri), ":.")

        diff = diff
          .. string.format(
            "diff --code-actions a/%s b/%s\n",
            old_path,
            new_path
          )
        diff = diff .. string.format("rename from %s\n", old_path)
        diff = diff .. string.format("rename to %s\n", new_path)
        diff = diff .. "\n"
      elseif change.kind == "create" then
        local path = vim.fn.fnamemodify(vim.uri_to_fname(change.uri), ":.")

        diff = diff
          .. string.format("diff --code-actions a/%s b/%s\n", path, path)
        diff = diff .. "new file\n"
        diff = diff .. "\n"
      elseif change.kind == "delete" then
        local path = vim.fn.fnamemodify(vim.uri_to_fname(change.uri), ":.")

        diff = diff
          .. string.format("diff --code-actions a/%s b/%s\n", path, path)
        diff = diff .. "\n"
      elseif change.kind then
        -- do nothing
      else
        local path =
          vim.fn.fnamemodify(vim.uri_to_fname(change.textDocument.uri), ":.")

        diff = diff
          .. string.format("diff --code-actions a/%s b/%s\n", path, path)
        diff = diff
          ---@diagnostic disable-next-line: param-type-mismatch
          .. vim.trim(diff_text_document_edit(change, offset_encoding))
          .. "\n"
        diff = diff .. "\n"
      end
    end

    return diff
  end

  local all_changes = workspace_edit.changes
  if all_changes and not vim.tbl_isempty(all_changes) then
    for uri, changes in pairs(all_changes) do
      local bufnr = vim.uri_to_bufnr(uri)

      diff = diff
        .. table.concat({
          ---@diagnostic disable-next-line: param-type-mismatch
          vim.trim(diff_text_edits(changes, bufnr, offset_encoding)),
        }, "\n")
    end
  end

  return diff
end

---@param action nio.lsp.types.CodeAction | nio.lsp.types.Command
---@param client nio.lsp.Client
local function apply_code_action(action, client, ctx)
  local util = vim.lsp.util
  if action.edit then
    util.apply_workspace_edit(
      action.edit --[[@as lsp.WorkspaceEdit]],
      client.server_capabilities.positionEncoding or "utf-8"
    )
  end
  if action.command then
    local command = type(action.command) == "table" and action.command
      or action
    if type(command) == "string" then
      command = {
        title = action.title,
        command = command,
        arguments = {},
      }
    end
    ---@cast command nio.lsp.types.Command
    local err, res = client.request.workspace_executeCommand(
      {
        command = command.command,
        arguments = command.arguments,
      },
      ctx.bufnr or 0,
      {
        timeout = 1000,
      }
    )
    if err then
      vim.notify(err.code .. ": " .. err.message, vim.log.levels.ERROR)
      return
    end
    if res and type(res) == "table" then
      if res.edit then
        util.apply_workspace_edit(
          action.edit --[[@as lsp.WorkspaceEdit]],
          client.server_capabilities.positionEncoding or "utf-8"
        )
      end
    end
  end
end

local function exec_selected_action(action_tuple, ctx)
  if not action_tuple then
    return
  end
  ---@type nio.lsp.Client?
  local client = action_tuple[1]
  if not client then
    vim.notify("No client found for selected action", vim.log.levels.ERROR)
    return
  end
  local action = action_tuple[2]

  local supports_resolve = type(client.server_capabilities.codeActionProvider)
      == "table"
    and client.server_capabilities.codeActionProvider.resolveProvider

  if not action.edit and client and supports_resolve then
    local err, resolved_action =
      client.request.codeAction_resolve(action, ctx.bufnr, {
        timeout = 1000,
      })
    if err then
      vim.notify(err.code .. ": " .. err.message, vim.log.levels.ERROR)
      return
    end
    if not resolved_action then
      return
    end
    apply_code_action(resolved_action, client, ctx)
  else
    apply_code_action(action, client, ctx)
  end
end

---@param client_actions { client: nio.lsp.Client, error: any, result: nio.lsp.types.CodeAction[] }
local function parse_client_actions(client_actions)
  local groups = {}
  local ungrouped = vim
    .iter(client_actions)
    :filter(function(action)
      return action.error == nil and action.result ~= nil
    end)
    :map(
      ---@param action { client: nio.lsp.Client, error: any, result: nio.lsp.types.CodeAction[] }
      function(action)
        local res = {}
        for _, act in ipairs(action.result) do
          -- TODO: action groups
          -- if action.group then
          --   local group = groups[action.group]
          --   if not group then
          --     group = {}
          --     groups[action.group] = group
          --   end
          --   table.insert(group, { client, action })
          -- else
          -- end
          table.insert(res, { action.client, act })
        end
        return res
      end
    )
    :fold({}, function(acc, actions)
      vim.list_extend(acc, actions)
      return acc
    end)
  return ungrouped, groups
end

local function format_item(item)
  local title = item[2].title:gsub("\r\n", "\\r\\n")
  return ({ title:gsub("\n%s+", ""):gsub("\n", "\\n") })[1]
end

local function preview_create_buf(curbuf, symbol)
  local buf = symbol.entry.menu.preview_buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_create_buf(false, true)
  end
  vim.bo[buf].filetype = vim.bo[curbuf].filetype
  return buf
end

local function preview_render_buf(preview_buf, edit, offset_encoding)
  local text = vim
    .iter(
      vim.split(
        diff_workspace_edit(edit, offset_encoding) or "",
        "\n",
        { trimempty = false }
      )
    )
    -- :skip(3)
    :filter(function(line)
      return not vim.startswith(line, "@@")
    end)
    :totable()
  local new_text = {}
  local add_lines = {}
  local del_lines = {}
  local min_indent
  for i, line in ipairs(text) do
    if line:sub(1, 1) == "+" then
      table.insert(add_lines, i)
      line = line:gsub("^+", " ")
    elseif line:sub(1, 1) == "-" then
      table.insert(del_lines, i)
      line = line:gsub("^-", " ")
    end
    if line:match("^%s+") then
      if min_indent then
        min_indent = math.min(min_indent, string.len(line:match("^%s*") or ""))
      else
        min_indent = string.len(line:match("^%s*") or "")
      end
    end
    table.insert(new_text, line)
  end
  local max_line_len = 0
  min_indent = min_indent or 0
  for i, _ in ipairs(new_text) do
    new_text[i] = new_text[i]:sub(min_indent + 1)
    max_line_len = math.max(max_line_len, string.len(new_text[i]))
  end
  vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, new_text)
  local ns = vim.api.nvim_create_namespace("dropbar-code-action-preview")
  for _, i in ipairs(add_lines) do
    vim.api.nvim_buf_add_highlight(preview_buf, ns, "DiffAdd", i - 1, 0, -1)
  end
  for _, i in ipairs(del_lines) do
    vim.api.nvim_buf_add_highlight(preview_buf, ns, "DiffDelete", i - 1, 0, -1)
  end
  return max_line_len
end

---@param symbol dropbar_symbol_t
local function preview_open_win(symbol, preview_buf, max_line_len)
  ---@diagnostic disable-next-line: undefined-field
  local win = symbol.entry.menu.preview_win
  if not win or not vim.api.nvim_win_is_valid(win) then
    local zindex = 99
    if symbol.entry.menu._win_configs.zindex then
      zindex = symbol.entry.menu._win_configs.zindex - 1
    end

    local positions = {}
    local width = math.min(80, math.max(50, max_line_len + 2))
    local height = math.min(vim.api.nvim_buf_line_count(preview_buf), 15)

    positions.left = {
      col = -(width + 1),
      row = -1,
    }

    positions.right = {
      col = vim.api.nvim_win_get_width(0) + 1,
      row = -1,
    }

    local space_right = vim.o.columns
      - (vim.api.nvim_win_get_position(0)[2] + vim.api.nvim_win_get_width(0))
    local space_left = vim.api.nvim_win_get_position(0)[2]

    local layout = "right"
    if space_right > space_left then
      layout = "right"
      if (space_right - 2) < width then
        width = space_right - 2
      end
    else
      layout = "left"
      if (space_left - 2) < width then
        width = space_left - 2
      end
    end

    win = vim.api.nvim_open_win(
      preview_buf,
      false,
      vim.tbl_deep_extend("keep", positions[layout], {
        relative = "win",
        focusable = false,
        style = "minimal",
        zindex = zindex,
        width = width,
        height = height,
      })
    )

    for k, v in pairs({
      statuscolumn = "",
      signcolumn = "no",
      foldcolumn = "0",
    }) do
      vim.api.nvim_set_option_value(k, v, {
        win = win,
      })
    end
  end
  return win
end

---@param symbol dropbar_symbol_t
local function preview_item(symbol, item, bufnr)
  if item[2].edit then
    local preview_buf = preview_create_buf(bufnr, symbol)
    local max_line_len = preview_render_buf(
      preview_buf,
      item[2].edit,
      ---@diagnostic disable-next-line: deprecated
      vim.lsp.util._get_offset_encoding(bufnr)
    )
    if
      symbol.entry.menu.preview_win
      and vim.api.nvim_win_is_valid(symbol.entry.menu.preview_win)
    then
      vim.api.nvim_win_set_buf(symbol.entry.menu.preview_win, preview_buf)
    else
      ---@diagnostic disable-next-line: inject-field
      symbol.entry.menu.preview_win =
        preview_open_win(symbol, preview_buf, max_line_len)
    end
  end
end

---@param symbol dropbar_symbol_t
local function preview_restore_view(symbol)
  local win = symbol.entry.menu.preview_win
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  ---@diagnostic disable-next-line: inject-field
  symbol.entry.menu.preview_win = nil
end

local M = {}

M.code_actions = function(options)
  options = options or {}

  local a = require("nio")
  local util = vim.lsp.util

  local bufnr = vim.api.nvim_get_current_buf()

  a.run(function()
    local clients = a.lsp.get_clients({
      bufnr = bufnr,
      method = "textDocument/codeAction",
    })

    ---@type nio.lsp.types.CodeActionParams
    local params = util.make_range_params(
      nil,
      clients[1] and clients[1].server_capabilities.positionEncoding or "utf-8"
    )
    ---@type nio.lsp.types.CodeActionContext
    local context = {
      ---@type nio.lsp.types.Diagnostic[]
      diagnostics = {},
    }
    context.triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Invoked
    context.diagnostics = vim.diagnostic.get(bufnr, {
      lnum = params.range.start.line,
    })
    params.context = context

    local opts = {
      -- timeout = 250,
    }

    local req_thunks = vim
      .iter(clients)
      :map(
        ---@param client nio.lsp.Client
        function(client)
          return function()
            local err, res =
              client.request.textDocument_codeAction(params, bufnr, opts)
            return {
              error = err,
              result = res,
              client = client,
            }
          end
        end
      )
      :totable()
    ---@type (nio.lsp.types.CodeAction[]|nio.lsp.types.Command|nil)[]
    local client_actions = a.gather(req_thunks)

    -- local client_actions = vim.iter(results):fold({}, function(tbl, res)
    --   if type(res) == "table" then
    --     vim.list_extend(tbl, res)
    --   else
    --     table.insert(tbl, res)
    --   end
    --   return tbl
    -- end)

    -- local client_actions =
    --   a.lsp.buf_request_all(bufnr, "textDocument/codeAction", params)

    local actions = parse_client_actions(client_actions)

    if vim.tbl_isempty(actions) then
      vim.notify("No code actions available", vim.log.levels.INFO, {})
      return
    end

    local selection = a.ui.select(actions, {
      prompt = "Code actions:",
      kind = "codeaction",
      format_item = format_item,
      preview = function(self, item)
        preview_item(self, item, bufnr)
      end,
      preview_close = preview_restore_view,
    })

    exec_selected_action(selection, context)
  end)
end

function M.setup()
  vim.lsp.buf.code_action = M.code_actions
end

return setmetatable(M, {
  __call = function(_, ...)
    return M.code_actions(...)
  end,
})
