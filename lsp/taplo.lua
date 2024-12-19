local defaults = require("lspconfig.configs.taplo").default_config
local settings = require("neoconf").get("lspconfig.taplo", {}, { lsp = true })

vim.lsp.config.taplo = vim.tbl_extend("force", defaults, {
  settings = settings,
  root_markers = {
    ".git",
    "Cargo.toml",
  },
})
