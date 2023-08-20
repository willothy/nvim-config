local lsp = require("configs.lsp")

require("rust-tools").setup({
  tools = {
    inlay_hints = {
      auto = false,
    },
  },
  server = {
    on_attach = lsp.lsp_attach,
  },
})
vim.cmd.LspStart("rust_analyzer")
