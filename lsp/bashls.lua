local defaults = require("lspconfig.configs.bashls").default_config
local settings = require("neoconf").get("lspconfig.bashls", {}, { lsp = true })

vim.lsp.config.bashls = vim.tbl_extend("force", defaults, {
  settings = settings,
  filetypes = { "zsh", "sh", "bash" },
  root_markers = { ".git", ".zshrc", ".bashrc" },
})
