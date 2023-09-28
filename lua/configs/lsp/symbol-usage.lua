local SymbolKind = vim.lsp.protocol.SymbolKind

local lua = require("symbol-usage.langs").lua.kinds_filter

local ext = {
  [SymbolKind.Function] = {
    function(data)
      return data.parent.kind ~= SymbolKind.Function
    end,
  },
}
for key, value in pairs(ext) do
  if not lua[key] then
    lua[key] = {}
  end
  for _, v in ipairs(value) do
    table.insert(lua[key], v)
  end
end

local opts = {
  hl = { link = "LspInlayHint" },
  kinds = {
    SymbolKind.Function,
    SymbolKind.Method,
  },
  vt_position = "above",
  -- request_pending_text = "",
  kinds_filter = {},
  references = {
    enabled = true,
    include_declaration = false,
  },
  implementation = { enabled = true },
}

require("symbol-usage").setup(opts)
