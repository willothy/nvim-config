vim.lsp.config("*", {
  capabilities = require("willothy.lsp.capabilities").make_capabilities(),
})

require("mason").setup()

-- require("lspconfig").lua_ls.setup({
--   capabilities = capabilities,
--   -- settings = settings("lua_ls"),
--   root_dir = require("lspconfig.util").root_pattern(
--     ".luarc.json",
--     ".luarc.jsonc",
--     ".luacheckrc",
--     ".stylua.toml",
--     "stylua.toml",
--     "selene.toml",
--     "selene.yml",
--     ".git"
--   ),
-- })

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
        -- else
        --   vim.notify(
        --     string.format("LSP server not found: %s", server_name),
        --     vim.log.levels.WARN,
        --     {
        --       title = "LSP",
        --     }
        --   )
      end
    end,
  },
})

vim.lsp.enable("rust_analyzer")
vim.lsp.enable("lua_ls")

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
