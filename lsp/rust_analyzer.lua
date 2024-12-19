local default = require("lspconfig.configs.rust_analyzer").default_config

vim.lsp.config.rust_analyzer = vim.tbl_extend("force", default, {
  settings = require("neoconf").get(
    "lspconfig.rust_analyzer",
    {},
    { lsp = true }
  ),
})
