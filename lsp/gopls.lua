local defaults = require("lspconfig.configs.gopls").default_config
local settings = require("neoconf").get("lspconfig.gopls", {}, { lsp = true })

vim.lsp.config.gopls = vim.tbl_extend("force", defaults, {
  settings = settings,
  root_markers = { ".git", "go.work", "go.mod", "go.sum" },
})
