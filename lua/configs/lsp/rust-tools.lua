local lsp = require("configs.lsp")

require("rust-tools").setup({
  tools = {
    inlay_hints = {
      auto = false,
    },
  },
  server = {
    on_attach = lsp.lsp_attach,
    settings = lsp.lsp_settings["rust-analyzer"],
  },
})
vim.cmd.LspStart("rust_analyzer")
