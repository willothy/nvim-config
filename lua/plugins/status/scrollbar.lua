return {
  {
    "lewis6991/satellite.nvim",
    config = true,
    lazy = true,
    event = "VeryLazy",
    enabled = false,
  },
  {
    "petertriho/nvim-scrollbar",
    dependencies = {
      {
        "kevinhwang91/nvim-hlslens",
        config = function()
          require("scrollbar.handlers.search").setup({
            -- hlslens config overrides
          })
        end,
      },
      "lewis6991/gitsigns.nvim",
    },
    config = function()
      require("scrollbar").setup()
      -- require("scrollbar.handlers.gitsigns").setup()
    end,
    enabled = false,
  },
}
