vim.lsp.config.bufls = {
  cmd = { "bufls", "serve" },
  filetypes = { "proto" },
  root_markers = { "buf.work.yaml", ".git" },
  single_file_support = true,
}
