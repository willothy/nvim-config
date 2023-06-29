return {
  {
    "anuvyklack/windows.nvim",
    dependencies = {
      "anuvyklack/middleclass",
    },
    config = function()
      require("windows").setup({
        autowidth = {
          enable = true,
        },
        animation = {
          enable = false,
        },
      })
    end,
    lazy = true,
    event = "VeryLazy",
  },
  {
    "echasnovski/mini.animate",
    opts = {
      cursor = { enable = false },
      scroll = { enable = false },
    },
  },
}
