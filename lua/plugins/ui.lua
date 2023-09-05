local anyline = false

return {
  -- STARTUP --
  {
    "echasnovski/mini.starter",
    config = function()
      require("configs.ui.mini-starter")
    end,
    event = "VeryLazy",
    enabled = false,
  },
  -- LAYOUT / CORE UI --
  {
    -- "folke/edgy.nvim",
    "willothy/edgy.nvim",
    -- dir = "~/projects/lua/edgy.nvim/",
    event = "VeryLazy",
    config = function()
      require("configs.ui.edgy")
    end,
  },
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    event = "UiEnter",
    config = function()
      require("configs.ui.noice")
    end,
  },
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      require("configs.ui.notify")
    end,
  },
  -- SCOPE / CURSORWORD --
  {
    "echasnovski/mini.indentscope",
    name = "mini.indentscope",
    enabled = not anyline,
    event = "VeryLazy",
    config = function()
      require("configs.ui.mini-indentscope")
    end,
  },
  {
    enabled = not anyline,
    "lukas-reineke/indent-blankline.nvim",
    branch = "v3",
  },
  {
    "willothy/anyline.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    enabled = anyline,
    event = "VeryLazy",
    config = function()
      require("configs.ui.anyline")
    end,
  },
  {
    "nyngwang/murmur.lua",
    event = "VeryLazy",
    config = function()
      require("configs.ui.murmur")
    end,
  },
  -- SIDEBARS --
  {
    "sidebar-nvim/sidebar.nvim",
    event = "User ExtraLazy",
    opts = function()
      return require("configs.ui.sidebars").sidebar
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "mrbjarksen/neo-tree-diagnostics.nvim",
    },
    event = "CmdlineEnter",
    opts = function()
      return require("configs.ui.sidebars").neotree
    end,
  },
  {
    "stevearc/aerial.nvim",
    opts = function()
      return require("configs.ui.sidebars").aerial
    end,
    event = "CmdlineEnter",
  },
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("configs.ui.icons")
    end,
  },
  -- WINDOWS --
  {
    "willothy/focus.nvim",
    branch = "resizer-fix-2",
    config = function()
      require("configs.windows.focus")
    end,
    event = "VeryLazy",
  },
  {
    "echasnovski/mini.animate",
    config = function()
      require("configs.windows.mini-animate")
    end,
    event = "VeryLazy",
  },
  {
    "willothy/nvim-window-picker",
    config = function()
      require("configs.windows.window-picker")
    end,
  },
  {
    "mrjones2014/smart-splits.nvim",
    config = function()
      require("configs.windows.smart-splits")
    end,
    event = "User ExtraLazy",
  },
  {
    "kwkarlwang/bufresize.nvim",
    config = function()
      require("configs.windows.bufresize")
    end,
  },
  {
    "tummetott/winshift.nvim",
    -- branch = "not_triggering_optionset_event",
    config = true,
    event = "CmdlineEnter",
  },
  {
    "willothy/winborder.nvim",
    config = true,
    enabled = false,
    event = "VeryLazy",
  },
  {
    "stevearc/stickybuf.nvim",
    config = true,
  },
  -- STATUS --
  {
    "willothy/nvim-cokeline",
    config = function()
      require("configs.status.cokeline")
    end,
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
    -- "Bekaboo/dropbar.nvim",
    "willothy/dropbar.nvim",
    branch = "feat-fuzzy-finding",
    -- dir = "~/projects/lua/dropbar.nvim/",
    config = function()
      require("configs.status.dropbar")
    end,
    event = "UiEnter",
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
    event = "User ExtraLazy",
    config = function()
      require("configs.status.incline")
    end,
  },
  -- COLORS --
  {
    "willothy/minimus",
    config = function()
      vim.api.nvim_exec2("colorscheme minimus", {})
    end,
    event = "UiEnter",
  },
  {
    "rktjmp/lush.nvim",
    event = "CmdlineEnter",
  },
  {
    "folke/tokyonight.nvim",
  },
}
