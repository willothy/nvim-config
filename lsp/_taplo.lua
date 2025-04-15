return {
  cmd = { "taplo", "lsp", "stdio" },
  filetypes = { "toml" },
  single_file_support = true,
  root_markers = {
    ".git",
    "Cargo.toml",
  },
}
