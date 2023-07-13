return {
  -- Color themes
  {
    "rktjmp/lush.nvim",
    cond = true,
  },
  {
    "willothy/minimus",
    dependencies = {
      "rktjmp/lush.nvim",
    },
    lazy = false,
    cond = true,
    priority = 1000,
  },
  {
    "nvim-zh/colorful-winsep.nvim",
    dependencies = {
      "willothy/minimus",
    },
    config = function()
      require("colorful-winsep").setup({
        highlight = {
          fg = (function() return require("minimus.palette").hex.blue end)(),
        },
      })
    end,
    lazy = true,
    event = { "WinNew", "WinEnter" },
  },
}
