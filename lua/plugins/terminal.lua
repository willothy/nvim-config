return {
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("configs.terminal.toggleterm")
    end,
  },
  {
    "willothy/flatten.nvim",
    cond = true,
    lazy = false,
    priority = 1000,
    config = function()
      require("configs.terminal.flatten")
    end,
  },
  {
    "willothy/wezterm.nvim",
    config = true,
  },
  {
    "desdic/greyjoy.nvim",
    dependencies = {
      "stevearc/overseer.nvim",
    },
    cmd = "Greyjoy",
    config = function()
      require("configs.terminal.greyjoy")
    end,
  },
}
