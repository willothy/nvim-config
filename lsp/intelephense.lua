local defaults = require("lspconfig.configs.intelephense").default_config
local settings = require("neoconf").get(
  "lspconfig.intelephense",
  {},
  { lsp = true }
)

vim.lsp.config.intelephense = vim.tbl_extend("force", defaults, {
  settings = settings,
})
