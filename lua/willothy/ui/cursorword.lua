-- Highlight other uses of the symbol under the cursor, flicker-free.
--
-- Unlike vim-illuminate, highlights are NOT cleared when the cursor moves.
-- They are cleared and re-applied atomically only when the new set is ready
-- (inside the async LSP response handler, or synchronously for the treesitter
-- fallback), so there is never a blank gap while waiting on the LSP.
--
-- Priority: LSP textDocument/documentHighlight -> treesitter identifier match.
local M = {}

local ns = vim.api.nvim_create_namespace("willothy_cursorword")
local au = vim.api.nvim_create_augroup("willothy_cursorword", { clear = true })

-- debounce after the cursor stops moving (ms)
local DELAY = 100
-- skip the treesitter fallback's full-tree walk above this many lines
local TS_MAX_LINES = 5000

local denylist = {
  ["neo-tree"] = true,
  noice = true,
  SidebarNvim = true,
  terminal = true,
  trouble = true,
}

-- documentHighlightKind -> highlight group. Kind 1 (Text) and unknown/nil map
-- to LspReferenceRead: many colorschemes (this one included) only style the
-- Read/Write groups and leave LspReferenceText invisible.
local kind_to_hl = {
  [1] = "LspReferenceRead",
  [2] = "LspReferenceRead",
  [3] = "LspReferenceWrite",
}

-- per-buffer request sequence, so a stale async response can't overwrite a
-- newer one
local seqs = {}

local function should_highlight(buf)
  return vim.api.nvim_buf_is_valid(buf)
    and vim.bo[buf].buftype == ""
    and not denylist[vim.bo[buf].filetype]
end

local function clear(buf)
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end
end

-- atomically replace the highlights for a buffer
---@param ranges { srow:integer, scol:integer, erow:integer, ecol:integer, hl:string }[]
local function apply(buf, ranges)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, r in ipairs(ranges) do
    pcall(
      vim.hl.range,
      buf,
      ns,
      r.hl,
      { r.srow, r.scol },
      { r.erow, r.ecol },
      {}
    )
  end
end

-- convert an LSP (utf-16/8/32) character offset to a 0-indexed byte column
local function byte_col(buf, line, character, encoding)
  local text = vim.api.nvim_buf_get_lines(buf, line, line + 1, false)[1]
  if not text then
    return character
  end
  local ok, col = pcall(vim.str_byteindex, text, encoding, character, false)
  return ok and col or math.min(character, #text)
end

---@return boolean handled whether an LSP client took the request
local function lsp_update(buf, win)
  local clients = vim.lsp.get_clients({
    bufnr = buf,
    method = "textDocument/documentHighlight",
  })
  local client = clients[1]
  if not client then
    return false
  end

  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
  seqs[buf] = (seqs[buf] or 0) + 1
  local seq = seqs[buf]

  client:request("textDocument/documentHighlight", params, function(err, result)
    -- drop stale / superseded responses
    if err or seqs[buf] ~= seq or not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    if not result or #result == 0 then
      clear(buf)
      return
    end
    local enc = client.offset_encoding
    local ranges = {}
    for _, dh in ipairs(result) do
      local s, e = dh.range.start, dh.range["end"]
      ranges[#ranges + 1] = {
        srow = s.line,
        scol = byte_col(buf, s.line, s.character, enc),
        erow = e.line,
        ecol = byte_col(buf, e.line, e.character, enc),
        hl = kind_to_hl[dh.kind] or "LspReferenceRead",
      }
    end
    apply(buf, ranges)
  end, buf)

  return true
end

---@return boolean handled whether treesitter produced a result
local function treesitter_update(buf, win)
  if vim.api.nvim_buf_line_count(buf) > TS_MAX_LINES then
    return false
  end

  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then
    return false
  end
  parser:parse(true)

  local cursor = vim.api.nvim_win_get_cursor(win)
  local node = vim.treesitter.get_node({
    bufnr = buf,
    pos = { cursor[1] - 1, cursor[2] },
  })
  if not node then
    return false
  end
  local ntype = node:type()
  if not ntype:find("identifier") then
    return false
  end
  local text = vim.treesitter.get_node_text(node, buf)
  if not text or text == "" then
    return false
  end

  local ranges = {}
  local function walk(n)
    if n:named() and n:type() == ntype then
      if vim.treesitter.get_node_text(n, buf) == text then
        local sr, sc, er, ec = n:range()
        ranges[#ranges + 1] =
          { srow = sr, scol = sc, erow = er, ecol = ec, hl = "LspReferenceRead" }
      end
    end
    for child in n:iter_children() do
      walk(child)
    end
  end

  for _, tree in pairs(parser:trees()) do
    walk(tree:root())
  end

  apply(buf, ranges)
  return true
end

local function update()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  if not should_highlight(buf) then
    clear(buf)
    return
  end
  -- LSP takes priority; on success the highlights land later, in the handler
  if lsp_update(buf, win) then
    return
  end
  if treesitter_update(buf, win) then
    return
  end
  clear(buf)
end

local timer = assert((vim.uv or vim.loop).new_timer())
local function schedule()
  timer:stop()
  timer:start(DELAY, 0, vim.schedule_wrap(update))
end

function M.setup()
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = au,
    callback = schedule,
  })
  -- content changed -> current highlights may be stale; recompute (the apply
  -- still swaps atomically, so no flicker)
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = au,
    callback = schedule,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = au,
    callback = function(ev)
      seqs[ev.buf] = nil
    end,
  })
end

return M
