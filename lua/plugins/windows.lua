return {
  {
    "nvim-focus/focus.nvim",
    -- dir = "~/projects/lua/focus.nvim/",
    config = function()
      require("configs.windows.focus")
    end,
    event = "VeryLazy",
  },
  {
    "echasnovski/mini.animate",
    -- enabled = false,
    config = function()
      require("configs.windows.mini-animate")
    end,
    event = "VeryLazy",
  },
  {
    "willothy/nvim-window-picker",
    -- dir = "~/projects/lua/nvim-window-picker/",
    event = "User ExtraLazy",
    config = function()
      require("configs.windows.window-picker")
    end,
  },
  {
    "mrjones2014/smart-splits.nvim",
    config = function()
      require("configs.windows.smart-splits")
    end,
    event = "VeryLazy",
  },
  {
    "kwkarlwang/bufresize.nvim",
    event = "VeryLazy",
    config = function()
      require("configs.windows.bufresize")
    end,
  },
  {
    "tummetott/winshift.nvim",
    -- branch = "not_triggering_optionset_event",
    config = true,
    cmd = "WinShift",
  },
  {
    "willothy/winborder.nvim",
    -- dir = "~/projects/lua/winborder.nvim/",
    config = true,
    enabled = false,
    event = "VeryLazy",
  },
  {
    "stevearc/stickybuf.nvim",
    config = true,
    event = "User ExtraLazy",
  },
}
