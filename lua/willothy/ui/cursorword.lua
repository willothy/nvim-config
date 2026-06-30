-- Highlight other uses of the symbol under the cursor, flicker-free.
--
-- Unlike vim-illuminate, highlights are NOT cleared when the cursor moves.
-- They are cleared and re-applied atomically only when the new set is ready
-- (inside the async LSP response handler, or synchronously for the fallbacks),
-- so there is never a blank gap while waiting on the LSP.
--
-- Provider priority, first to produce a result wins:
--   1. LSP   textDocument/documentHighlight (async, semantic)
--   2. treesitter  same-identifier match (sync, scope-unaware)
--   3. regex  whole-word match in the buffer (sync, works in prose/markdown)
local M = {}

local ns = vim.api.nvim_create_namespace("willothy_cursorword")
-- the augroup is (re)created inside setup(), NOT at module load: a top-level
-- clear=true would wipe the autocmds a prior setup() registered if this file is
-- ever re-run (module reload).
local au

-- debounce after the cursor stops moving (ms)
local DELAY = 40
-- skip the synchronous fallbacks' buffer scans above this many lines
local MAX_LINES = 5000

local denylist = {
  ["neo-tree"] = true,
  noice = true,
  SidebarNvim = true,
  terminal = true,
  trouble = true,
}

-- documentHighlightKind -> highlight group. The treesitter/regex paths and
-- unknown kinds use LspReferenceText. Style LspReference{Text,Read,Write} in
-- your colorscheme to taste.
local kind_to_hl = {
  [1] = "LspReferenceText",
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
  -- bump the request sequence so an in-flight LSP response is dropped instead
  -- of re-applying a highlight after we've intentionally cleared (e.g. when the
  -- cursor moved onto punctuation while a request for the previous word was
  -- still pending)
  seqs[buf] = (seqs[buf] or 0) + 1
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

---@param client vim.lsp.Client a documentHighlight-capable client for the buffer
local function lsp_update(buf, win, client)
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
        hl = kind_to_hl[dh.kind] or "LspReferenceText",
      }
    end
    apply(buf, ranges)
  end, buf)
end

---@return boolean handled whether treesitter produced a result
local function treesitter_update(buf, win)
  if vim.api.nvim_buf_line_count(buf) > MAX_LINES then
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
          { srow = sr, scol = sc, erow = er, ecol = ec, hl = "LspReferenceText" }
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

---@return boolean handled whether a word match was produced
local function regex_update(buf, win)
  if vim.api.nvim_buf_line_count(buf) > MAX_LINES then
    return false
  end

  local cursor = vim.api.nvim_win_get_cursor(win)
  local cur_line = vim.api.nvim_buf_get_lines(buf, cursor[1] - 1, cursor[1], false)[1]
    or ""
  local col = cursor[2]
  -- the char under the cursor must be part of a word; this also guards against
  -- expand("<cword>") raising E348 ("No string under cursor") on blank lines
  if not (cur_line:sub(col + 1, col + 1)):match("[%w_]") then
    return false
  end
  local ok_cword, cword = pcall(vim.fn.expand, "<cword>")
  if not ok_cword or cword == "" or not cword:match("^[%w_]+$") then
    return false
  end

  local pat = "%f[%w_]" .. vim.pesc(cword) .. "%f[^%w_]"
  local ranges = {}
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i, line in ipairs(lines) do
    local init = 1
    while true do
      local s, e = line:find(pat, init)
      if not s then
        break
      end
      ranges[#ranges + 1] =
        { srow = i - 1, scol = s - 1, erow = i - 1, ecol = e, hl = "LspReferenceText" }
      init = e + 1
    end
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
  -- only highlight while the cursor is on a word character; clear on
  -- punctuation/whitespace so a trailing char doesn't keep a word highlighted
  local cursor = vim.api.nvim_win_get_cursor(win)
  local line = vim.api.nvim_buf_get_lines(buf, cursor[1] - 1, cursor[1], false)[1]
    or ""
  if not line:sub(cursor[2] + 1, cursor[2] + 1):match("[%w_]") then
    clear(buf)
    return
  end
  -- one get_clients call; an LSP documentHighlight client takes priority and
  -- its highlights land later in the handler
  local clients = vim.lsp.get_clients({ bufnr = buf })
  for _, client in ipairs(clients) do
    if client:supports_method("textDocument/documentHighlight") then
      lsp_update(buf, win, client)
      return
    end
  end
  -- no documentHighlight-capable client: only use the treesitter/regex fallback
  -- when there's no LSP attached at all. Otherwise a client is still
  -- initialising and will provide highlights shortly, so don't flash broad
  -- fallback matches across the buffer during startup.
  if #clients == 0 then
    if treesitter_update(buf, win) then
      return
    end
    if regex_update(buf, win) then
      return
    end
  end
  clear(buf)
end

local timer = assert((vim.uv or vim.loop).new_timer())
local function schedule()
  timer:stop()
  timer:start(DELAY, 0, vim.schedule_wrap(update))
end

function M.setup()
  au = vim.api.nvim_create_augroup("willothy_cursorword", { clear = true })
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
  -- when an LSP attaches, re-highlight so its scoped results replace any
  -- treesitter/regex fallback that was showing while it loaded
  vim.api.nvim_create_autocmd("LspAttach", {
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
