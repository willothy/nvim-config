local defaults = require("lspconfig.configs.clangd").default_config
local settings = require("neoconf").get("lspconfig.clangd", {})

vim.lsp.config.clangd = vim.tbl_extend("force", defaults, {
  settings = settings,
  on_attach = function(_client, bufnr)
    vim.keymap.set("n", "<leader>gh", "<cmd>ClangdSwitchSourceHeader<CR>", {
      lhs = "<leader>gh",
      mode = "n",
      silent = true,
      noremap = true,
      buffer = bufnr,
      desc = "header / source",
    })
  end,
})
