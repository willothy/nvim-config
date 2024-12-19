local defaults = require("lspconfig.configs.tsserver").default_config
local settings = require("neoconf").get(
  "lspconfig.tsserver",
  {},
  { lsp = true }
)

vim.lsp.config.tsserver = vim.tbl_extend("force", defaults, {
  settings = settings,
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
})
