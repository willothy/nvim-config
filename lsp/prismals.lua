vim.lsp.config.prismals = {
  cmd = { "prisma-language-server", "--stdio" },
  filetypes = { "prisma" },
  settings = {
    prisma = {
      prismaFmtBinPath = "",
    },
  },
  root_markers = { ".git", "package.json" },
}
