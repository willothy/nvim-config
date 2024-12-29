vim.lsp.config.intelephense = {
  cmd = { "intelephense", "--stdio" },
  filetypes = { "php" },
  root_markers = {
    "composer.json",
    ".git",
  },
}
