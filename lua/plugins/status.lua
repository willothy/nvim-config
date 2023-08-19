return {
  -- STATUS --
  {
    "willothy/nvim-cokeline",
    dir = "~/projects/lua/cokeline/",
    config = function()
      require("configs.status.cokeline")
    end,
    event = "UiEnter",
  },
  {
    "willothy/lazyline.nvim",
    dir = "~/projects/lua/lazyline/",
    config = function()
      require("configs.status.lazyline")
    end,
    enabled = false,
    event = "UiEnter",
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
    event = "UiEnter",
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
}
