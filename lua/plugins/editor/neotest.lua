return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "rouge8/neotest-rust",
    },
    lazy = true,
    event = "LspAttach",
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-rust"),
        },
        summary = {
          enabled = true,
          animated = true,
        },
        diagnostic = {
          enabled = true,
          severity = vim.diagnostic.severity.ERROR,
        },
        status = {
          enabled = true,
          virtual_text = true,
          signs = true,
        },
      })
    end,
  },
}
