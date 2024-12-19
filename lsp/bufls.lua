local defaults = require("lspconfig.configs.bufls").default_config
local settings = require("neoconf").get("lspconfig.bufls", {}, { lsp = true })

vim.lsp.config.bufls = vim.tbl_extend("force", defaults, {
  filetypes = { "proto" },
  settings = settings,
})
