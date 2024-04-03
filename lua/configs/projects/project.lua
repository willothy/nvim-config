require("project_nvim").setup({
  detection_methods = {
    "lsp",
    "pattern",
  },
  patterns = {
    ".git",
    "package.json",
    "Cargo.toml",
    "Makefile",
  },
  exclude_dirs = {
    "~/.local/",
    "~/.cargo/",
  },
  ignore_lsp = { "null-ls", "savior", "copilot" },
  silent_chdir = true,
  show_hidden = true,
  scope_chdir = "tab",
})
