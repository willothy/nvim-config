---@param client lsp.Client
---@param bufnr integer
local function lsp_attach(client)
  require("lsp-format").on_attach(client)
end

return {
  lsp_attach = lsp_attach,
}
