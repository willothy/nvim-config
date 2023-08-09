return {
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("configs.terminal.toggleterm")
    end,
  },
  {
    "willothy/flatten.nvim",
    dir = "~/projects/lua/flatten/",
    dependencies = {
      -- hacky way of ensuring fileline deals with files before flatten sends them
      "lewis6991/fileline.nvim",
    },
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
    cmd = "WeztermSpawn",
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
