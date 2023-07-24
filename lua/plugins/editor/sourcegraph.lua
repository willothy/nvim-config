return {
  {
    "sourcegraph/sg.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "User ExtraLazy",
    config = function()
      require("sg").setup({
        on_attach = require("willothy.lsp").lsp_attach,
      })
    end,
    build = "nvim -l build/init.lua",
  },
}
