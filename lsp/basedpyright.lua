local defaults = require("lspconfig.configs.basedpyright").default_config
local settings = require("neoconf").get(
  "lspconfig.basedpyright",
  {},
  { lsp = true }
)

vim.lsp.config.basedpyright = vim.tbl_extend("force", defaults, {
  settings = settings,
  root_markers = { "pyproject.toml", ".git" },
})
