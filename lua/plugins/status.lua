return {
  {
    "willothy/nvim-cokeline",
    dir = "~/projects/lua/cokeline/",
    config = function()
      require("configs.status.cokeline")
    end,
    event = "User ExtraLazy",
  },
  {
    "rebelot/heirline.nvim",
    config = function()
      require("configs.status.heirline")
    end,
    event = "UiEnter",
  },
  {
    "Bekaboo/dropbar.nvim",
    config = function()
      require("configs.status.dropbar")
    end,
    event = "VeryLazy",
  },
  {
    "luukvbaal/statuscol.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
    },
    event = "User ExtraLazy",
    config = function()
      require("configs.status.statuscol")
    end,
  },
  {
    "willothy/incline.nvim",
    -- dir = "~/projects/lua/incline.nvim/",
    event = "User ExtraLazy",
    config = function()
      require("configs.status.incline")
    end,
  },
  {
    "lewis6991/satellite.nvim",
    event = "User VeryLazy",
    enabled = false,
    opts = {
      width = 1,
    },
  },
}
