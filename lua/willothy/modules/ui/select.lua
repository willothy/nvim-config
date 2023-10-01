---@diagnostic disable: inject-field
--- UI select module using Dropbar.nvim

-- utils for code actions

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
    ---@diagnostic disable-next-line: return-type-mismatch
    return vim.str_byteindex(line, index, true)
  elseif encoding == "utf-32" then
    ---@diagnostic disable-next-line: return-type-mismatch
    return vim.str_byteindex(line, index)
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
        t = vim.lsp.util.parse_snippet(t)
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

  return vim.diff(
    old_text .. "\n",
    table.concat(lines, eol) .. "\n",
    { ctxlen = 3 }
  )
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
        diff = diff .. string.format("--- a/%s\n", path)
        diff = diff .. "+++ /dev/null\n"
        diff = diff .. "\n"
      elseif change.kind then
        -- do nothing
      else
        local path =
          vim.fn.fnamemodify(vim.uri_to_fname(change.textDocument.uri), ":.")

        diff = diff
          .. string.format("diff --code-actions a/%s b/%s\n", path, path)
        diff = diff .. string.format("--- a/%s\n", path)
        diff = diff .. string.format("+++ b/%s\n", path)
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
      local path = vim.fn.fnamemodify(vim.uri_to_fname(uri), ":.")
      local bufnr = vim.uri_to_bufnr(uri)

      diff = diff
        .. table.concat({
          string.format("diff --code-actions a/%s b/%s", path, path),
          string.format("--- a/%s", path),
          string.format("+++ b/%s", path),
          ---@diagnostic disable-next-line: param-type-mismatch
          vim.trim(diff_text_edits(changes, bufnr, offset_encoding)),
          "",
          "",
        }, "\n")
    end
  end

  return diff
end

local M = {}

function M.ui_select(items, opts, on_choice)
  if not items then
    return
  end

  local dropbar_menu_t = require("dropbar.menu").dropbar_menu_t
  local dropbar_menu_entry_t = require("dropbar.menu").dropbar_menu_entry_t
  local dropbar_symbol_t = require("dropbar.bar").dropbar_symbol_t

  opts = opts or {}

  opts.prompt = opts.prompt and vim.trim(opts.prompt:gsub(":%s*$", ""))

  local entries = vim
    .iter(items)
    :enumerate()
    :map(function(idx, item)
      local text = item
      if opts.format_item then
        text = opts.format_item(item)
      end
      local virt_text
      local vt_pat = "%((.*)%)%s*%.?%s*$"
      if text:match(vt_pat) then
        virt_text = text:match(vt_pat)
        text = text:gsub(vt_pat, "")
      end
      return dropbar_menu_entry_t:new({
        virt_text = virt_text
          and { { " ", "NormalFloat" }, { virt_text, "Comment" } },
        components = {
          dropbar_symbol_t:new({
            icon = " ",
            icon_hl = "Special",
            name = text,
            preview = function(self)
              if opts.preview then
                opts.preview(self, item, idx)
              end
            end,
            preview_restore_view = function(self)
              if opts.preview_restore_view then
                opts.preview_restore_view(self, item, idx)
              end
            end,
            preview_restore_hl = function(self)
              if opts.preview_restore_hl then
                opts.preview_restore_hl(self, item, idx)
              end
            end,
            on_click = function(self)
              self.entry.menu:close()
              vim.schedule(function()
                if on_choice then
                  on_choice(item, idx)
                end
              end)
            end,
          }),
        },
      })
    end)
    :totable()

  local function virt_text_width(chunks)
    local total = 0
    for _, chunk in ipairs(chunks) do
      total = total + vim.fn.strcharlen(chunk[1])
    end
    return total
  end

  local width = math.min(
    math.max(
      vim
        .iter(entries)
        :map(function(entry)
          return math.max(
            entry:displaywidth(),
            entry.virt_text and (virt_text_width(entry.virt_text) + 2) or 0
          )
        end)
        :fold(0, math.max),
      opts.prompt and (vim.fn.strcharlen(opts.prompt) + 2) or 0,
      16
    ),
    math.floor(vim.o.columns / 2)
  )

  local height = math.min(
    12,
    math.max(
      vim.iter(entries):fold(0, function(acc, entry)
        return acc + (entry.virt_text and 2 or 1)
      end),
      3
    )
  )

  local menu = dropbar_menu_t:new({
    entries = entries,
    prev_win = vim.api.nvim_get_current_win(),
    win_configs = {
      relative = "cursor",
      title = opts.prompt,
      row = 1,
      col = 1,
      width = width,
      height = height,
      border = opts.prompt and {
        " ",
        " ",
        " ",
        "",
        " ",
        " ",
        " ",
        "",
      },
      title_pos = opts.prompt and "center",
      zindex = 200,
    },
  })

  menu:open()

  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = menu.buf,
    callback = function()
      local cursor = vim.api.nvim_win_get_cursor(menu.win)
      local eventignore = vim.o.eventignore
      vim.o.eventignore = "all"
      vim.api.nvim_win_set_cursor(menu.win, {
        cursor[1],
        1,
      })
      menu:update_hover_hl({ cursor[1], 1 })
      vim.o.eventignore = eventignore
    end,
  })
end

local function apply_code_action(action, client, ctx)
  local util = vim.lsp.util
  if action.edit then
    util.apply_workspace_edit(action.edit, client.offset_encoding)
  end
  if action.command then
    local command = type(action.command) == "table" and action.command
      or action
    client._exec_cmd(command, ctx)
  end
end

local function exec_selected_action(action_tuple, ctx)
  if not action_tuple then
    return
  end
  local client = vim.lsp.get_client_by_id(action_tuple[1])
  if not client then
    vim.notify("No client found for selected action", vim.log.levels.ERROR)
    return
  end
  local action = action_tuple[2]

  ---@diagnostic disable-next-line: invisible
  local reg = client.dynamic_capabilities:get(
    "textDocument/codeAction",
    { bufnr = ctx.bufnr }
  )

  local supports_resolve = vim.tbl_get(
    reg or {},
    "registerOptions",
    "resolveProvider"
  ) or client.supports_method("codeAction/resolve")

  if not action.edit and client and supports_resolve then
    client.request("codeAction/resolve", action, function(err, resolved_action)
      if err then
        vim.notify(err.code .. ": " .. err.message, "error")
        return
      end
      apply_code_action(resolved_action, client, ctx)
    end, ctx.bufnr)
  else
    apply_code_action(action, client, ctx)
  end
end

M.code_actions = function(options)
  options = options or {}

  local a = require("micro-async")
  local util = vim.lsp.util

  local bufnr = vim.api.nvim_get_current_buf()

  a.void(function()
    local context = {}
    context.triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Invoked
    context.diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr)

    local params = util.make_range_params()
    params.context = context

    local client_actions =
      a.lsp.buf_request_all(bufnr, "textDocument/codeAction", params)

    local actions = vim
      .iter(pairs(client_actions))
      :filter(function(_, actions)
        return actions.error == nil and actions.result ~= nil
      end)
      :map(function(client, actions)
        return vim
          .iter(actions.result)
          :map(function(action)
            return { client, action }
          end)
          :totable()
      end)
      :fold({}, function(acc, actions)
        vim.list_extend(acc, actions)
        return acc
      end)

    if vim.tbl_isempty(actions) then
      vim.notify("No code actions available", "info")
      return
    end

    local selection = a.ui.select(actions, {
      prompt = "Code actions:",
      kind = "codeaction",
      format_item = function(action_tuple)
        local title = action_tuple[2].title:gsub("\r\n", "\\r\\n")
        return title:gsub("\n%s+", ""):gsub("\n", "\\n")
      end,
      ---@param self dropbar_symbol_t
      preview = function(self, item)
        if item[2].edit then
          self.entry.menu.preview_buf = (
            self.entry.menu.preview_buf
            and vim.api.nvim_buf_is_valid(self.entry.menu.preview_buf)
          )
              and self.entry.menu.preview_buf
            or vim.api.nvim_create_buf(false, true)
          local text = vim
            .iter(
              vim.split(
                diff_workspace_edit(
                  item[2].edit,
                  vim.lsp.util._get_offset_encoding(bufnr)
                ) or "",
                "\n",
                { trimempty = true }
              )
            )
            :skip(3)
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
                min_indent =
                  math.min(min_indent, string.len(line:match("^%s*") or ""))
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
          text = new_text
          vim.api.nvim_buf_set_lines(
            self.entry.menu.preview_buf,
            0,
            -1,
            false,
            text
          )
          vim.bo[self.entry.menu.preview_buf].filetype = vim.bo[bufnr].filetype
          local ns =
            vim.api.nvim_create_namespace("dropbar-code-action-preview")
          for _, i in ipairs(add_lines) do
            vim.api.nvim_buf_add_highlight(
              self.entry.menu.preview_buf,
              ns,
              "DiffAdd",
              i - 1,
              0,
              -1
            )
          end
          for _, i in ipairs(del_lines) do
            vim.api.nvim_buf_add_highlight(
              self.entry.menu.preview_buf,
              ns,
              "DiffDelete",
              i - 1,
              0,
              -1
            )
          end
          self.entry.menu.preview_win = (
            self.entry.menu.preview_win
            and vim.api.nvim_win_is_valid(self.entry.menu.preview_win)
          )
              and self.entry.menu.preview_win
            or vim.api.nvim_open_win(self.entry.menu.preview_buf, false, {
              relative = "win",
              focusable = false,
              height = math.min(#text, 15),
              width = math.min(80, math.max(50, max_line_len + 2)),
              row = -1,
              col = vim.api.nvim_win_get_width(0) + 1,
              style = "minimal",
            })
        end
      end,
      ---@param self dropbar_symbol_t
      preview_restore_view = function(self)
        if
          self.entry.menu.preview_win
          and vim.api.nvim_win_is_valid(self.entry.menu.preview_win)
        then
          vim.api.nvim_win_close(self.entry.menu.preview_win, true)
          self.entry.menu.preview_win = nil
        end
      end,
    })

    exec_selected_action(selection, context)
  end)()
end

M.setup = function()
  vim.ui.select = M.ui_select
  vim.lsp.buf.code_action = M.code_actions
end

return setmetatable(M, {
  __call = function(_, ...)
    M.ui_select(...)
  end,
})
