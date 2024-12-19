local defaults = require("lspconfig.configs.gleam").default_config
local settings = require("neoconf").get("lspconfig.gleam", {}, { lsp = true })

vim.lsp.config.gleam = vim.tbl_extend("force", defaults, {
  settings = settings,
  root_markers = { ".git", "gleam.toml" },
})
