-- Jump to the "parent module" of the symbol under the cursor.
--
-- rust-analyzer exposes this directly via its `experimental/parentModule`
-- extension (the module that contains the current one). Other servers have no
-- such concept, so we fall back to the enclosing documentSymbol — i.e. one
-- structural level up (the function/class/namespace containing the cursor).
local M = {}

-- normalize a parentModule result (Location[] | LocationLink[] | single) to one
local function first_location(result)
  if type(result) ~= "table" then
    return nil
  end
  if result[1] then
    return result[1]
  end
  if result.uri or result.targetUri then
    return result
  end
  return nil
end

local function jump(location, offset_encoding)
  vim.lsp.util.show_document(
    location,
    offset_encoding,
    { reuse_win = false, focus = true }
  )
end

local function is_rust_analyzer(client)
  return client.name == "rust-analyzer" or client.name == "rust_analyzer"
end

-- rust-analyzer: experimental/parentModule
local function try_parent_module(client, bufnr, on_miss)
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
  client:request("experimental/parentModule", params, function(err, result)
    if err then
      on_miss()
      return
    end
    local target = first_location(result)
    if not target then
      on_miss()
      return
    end
    jump(target, client.offset_encoding)
  end, bufnr)
end

local function in_range(cursor, range)
  local line, col = cursor[1], cursor[2]
  local s, e = range.start, range["end"]
  local after = line > s.line or (line == s.line and col >= s.character)
  local before = line < e.line or (line == e.line and col <= e.character)
  return after and before
end

-- return the parent (one level up) of the innermost symbol containing the
-- cursor, or nil if the innermost symbol is already top-level
local function find_parent(symbols, cursor, parent)
  for _, sym in ipairs(symbols) do
    if sym.range and in_range(cursor, sym.range) then
      if sym.children and #sym.children > 0 then
        local deeper = find_parent(sym.children, cursor, sym)
        if deeper then
          return deeper
        end
      end
      return parent
    end
  end
  return nil
end

-- generic fallback: textDocument/documentSymbol -> enclosing symbol
local function try_document_symbol(client, bufnr, on_miss)
  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
  client:request("textDocument/documentSymbol", params, function(err, result)
    if err or type(result) ~= "table" then
      on_miss()
      return
    end
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local cursor = { cursor_pos[1] - 1, cursor_pos[2] }
    local parent = find_parent(result, cursor, nil)
    if not parent or not parent.range then
      on_miss()
      return
    end
    jump({
      uri = params.textDocument.uri,
      range = parent.selectionRange or parent.range,
    }, client.offset_encoding)
  end, bufnr)
end

--- Jump to the parent module (rust-analyzer) or enclosing symbol (fallback).
function M.goto_parent()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if #clients == 0 then
    vim.notify("No LSP client attached", vim.log.levels.WARN)
    return
  end

  for _, client in ipairs(clients) do
    if is_rust_analyzer(client) then
      try_parent_module(client, bufnr, function()
        vim.notify("No parent module", vim.log.levels.INFO)
      end)
      return
    end
  end

  for _, client in ipairs(clients) do
    if client:supports_method("textDocument/documentSymbol") then
      try_document_symbol(client, bufnr, function()
        vim.notify("No enclosing symbol", vim.log.levels.INFO)
      end)
      return
    end
  end

  vim.notify("No LSP client supports parent navigation", vim.log.levels.WARN)
end

return M
