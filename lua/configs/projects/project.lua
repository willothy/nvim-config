require("project_nvim").setup({
  detection_methods = {
    "lsp",
    "pattern",
  },
  patterns = {
    "^.config/",
    ".git",
    "Cargo.toml",
    "Makefile",
    -- "^~/projects/*/*/",
    "package.json",
  },
  exclude_dirs = {
    "~/.local/",
    "~/.cargo/",
  },
  ignore_lsp = { "null-ls", "savior", "copilot" },
  silent_chdir = false,
  show_hidden = true,
  scope_chdir = "tab",
})
