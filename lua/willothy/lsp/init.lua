vim.lsp.config("*", {
  capabilities = require("willothy.lsp.capabilities").make_capabilities(),
})

require("mason").setup()

local rename = {
  tsserver = "ts_ls",
}

require("mason-lspconfig").setup({
  ensure_installed = {},
  automatic_installation = false,
  handlers = {
    function(server_name)
      if
        #vim.api.nvim_get_runtime_file(
          string.format("lsp/%s.lua", server_name),
          true
        ) > 0
      then
        vim.lsp.enable(rename[server_name] or server_name)
      end
    end,
  },
})

vim.lsp.enable("rust_analyzer")
vim.lsp.enable("lua_ls")

require("lspconfig").lua_ls.setup({
  capabilities = require("willothy.lsp.capabilities").make_capabilities(),
  settings = vim.lsp.config.lua_ls.settings,
  root_dir = require("lspconfig.util").root_pattern(
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git"
  ),
})

for nvim_name, trouble_name in pairs({
  references = "lsp_references",
  definition = "lsp_definitions",
  type_definition = "lsp_type_definitions",
  implementation = "lsp_implementations",
  document_symbol = "lsp_document_symbols",
}) do
  vim.lsp.buf[nvim_name] = function()
    require("trouble").open({
      mode = trouble_name,
    })
  end
end
