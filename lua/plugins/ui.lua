return {
  -- EXTENRAL UIs --
  -- {
  --   "glacambre/firenvim",
  --   cond = vim.g.started_by_firenvim == true,
  --   lazy = false,
  --   build = function()
  --     vim.cmd("call firenvim#install(0)")
  --   end,
  -- },
  -- ??? --
  -- {
  --   "altermo/nwm",
  --   enabled = false,
  --   config = function()
  --     require("configs.ui.nwm")
  --   end,
  --   event = "VeryLazy",
  -- },
  -- LAYOUT / CORE UI --
  {
    -- "folke/which-key.nvim",
    "willothy/which-key.nvim", -- fork with fixes and description sort
    -- dir = "~/projects/lua/which-key.nvim/",
    config = function()
      require("configs.editor.which-key")
    end,
    event = "VeryLazy",
  },
  -- {
  --   "tamton-aquib/keys.nvim",
  --   cmd = "KeysToggle",
  -- },
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("configs.ui.icons")
    end,
  },
  {
    -- "folke/edgy.nvim",
    "willothy/edgy.nvim",
    -- event = "VeryLazy",
    config = function()
      require("configs.ui.edgy")
    end,
  },
  {
    "folke/zen-mode.nvim",
    opts = {
      on_open = function(win)
        vim.wo[win].fillchars = vim.go.fillchars
        vim.wo[win].winbar = "%{%v:lua.dropbar.get_dropbar_str()%}"
      end,
    },
    cmd = "ZenMode",
  },
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    event = "UiEnter",
    config = function()
      require("configs.ui.noice")
    end,
  },
  {
    "rcarriga/nvim-notify",
    config = function()
      require("configs.ui.notify")
    end,
  },
  {
    "3rd/image.nvim",
    enabled = false,
    dependencies = {
      "vhyrro/luarocks.nvim",
    },
    config = function()
      require("image").setup({})
    end,
  },
  -- SCOPE / CURSORWORD --
  {
    "echasnovski/mini.indentscope",
    dependencies = {
      -- Using both in conjunction looks nice.
      -- Indent-blankline is setup in the same file
      -- as mini.indentscope.
      "lukas-reineke/indent-blankline.nvim",
    },
    name = "mini.indentscope",
    event = "VeryLazy",
    config = function()
      require("configs.ui.mini-indentscope")
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
    cmd = {
      "SidebarNvimOpen",
      "SidebarNvimToggle",
    },
    opts = function()
      return require("configs.ui.sidebars").sidebar
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "main",
    dependencies = {
      "mrbjarksen/neo-tree-diagnostics.nvim",
    },
    cmd = "Neotree",
    opts = function()
      return require("configs.ui.sidebars").neotree
    end,
  },
  {
    "stevearc/aerial.nvim",
    opts = function()
      return require("configs.ui.sidebars").aerial
    end,
    cmd = {
      "AerialToggle",
      "AerialOpen",
      "AerialNavToggle",
      "AerialNavOpen",
    },
  },
  {
    "folke/trouble.nvim",
    --branch = "dev",
    -- dir = "~/projects/lua/trouble.nvim/",
    -- "willothy/trouble.nvim",
    cmd = "Trouble",
    -- branch = "fix-fillchars",
    config = function()
      require("configs.editor.trouble")
    end,
  },
  -- WINDOWS --
  {
    "nvim-focus/focus.nvim",
    -- "willothy/focus.nvim",
    -- branch = "float-config-preemptive-fix",
    dependencies = {
      "echasnovski/mini.animate",
    },
    config = function()
      vim.api.nvim_create_autocmd("WinEnter", {
        once = true,
        callback = function()
          require("configs.windows.focus")
        end,
      })
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
    event = "VeryLazy",
  },
  {
    "kwkarlwang/bufresize.nvim",
    config = function()
      require("configs.windows.bufresize")
    end,
  },
  {
    "tummetott/winshift.nvim",
    config = true,
    cmd = "WinShift",
  },
  {
    "stevearc/stickybuf.nvim",
    event = "VeryLazy",
    opts = {
      get_auto_pin = function(bufnr)
        -- Shell terminals will all have ft `terminal`, and can be switched between.
        -- They should be pinned by filetype only, not bufnr.
        if vim.bo[bufnr].filetype == "terminal" then
          return "filetype"
        end
        -- Non-shell terminals should be pinned by bufnr, not filetype.
        if vim.bo[bufnr].buftype == "terminal" then
          return "bufnr"
        end
        return require("stickybuf").should_auto_pin(bufnr)
      end,
    },
  },
  -- STATUS --
  {
    "willothy/nvim-cokeline",
    -- dir = "~/projects/lua/cokeline/",
    -- branch = "incremental-truncate",
    config = function()
      require("configs.status.cokeline")
    end,
    priority = 100,
    event = "UiEnter",
  },
  {
    "rebelot/heirline.nvim",
    config = function()
      require("configs.status.heirline")
    end,
    priority = 100,
    event = "UiEnter",
  },
  {
    "Bekaboo/dropbar.nvim",
    -- "willothy/dropbar.nvim",
    -- dir = "~/projects/lua/dropbar.nvim/",
    config = function()
      require("configs.status.dropbar")
    end,
    event = "UiEnter",
  },
  {
    "luukvbaal/statuscol.nvim",
    -- dir = "~/projects/lua/statuscol.nvim/",
    -- "willothy/statuscol.nvim",
    -- branch = "wip",
    dependencies = {
      "lewis6991/gitsigns.nvim",
    },
    event = "UiEnter",
    config = function()
      require("configs.status.statuscol")
    end,
  },
  -- NOTE: This seems to be broken atm (likely from 0.10 sign extmark changes)
  -- {
  --   "lewis6991/foldsigns.nvim",
  --   config = true,
  --   --
  --   event = "VeryLazy",
  -- },
  {
    "b0o/incline.nvim",
    -- branch = "dev",
    -- dir = "~/projects/lua/incline.nvim/",
    event = "VeryLazy",
    config = function()
      require("configs.status.incline")
    end,
  },
  {
    "goolord/alpha-nvim",
    dependencies = {
      "stevearc/resession.nvim",
    },
    config = function()
      require("configs.status.alpha")
    end,
    cmd = "Alpha",
  },
  -- COLORS --
  {
    "willothy/nvim-colorizer.lua",
    -- dir = "~/projects/lua/nvim-colorizer.lua/",
    config = function()
      require("colorizer").setup({
        user_default_options = {
          mode = "inline",
          names = false,
          virtualtext = "■ ",
        },
      })
    end,
    cmd = "ColorizerToggle",
  },
  {
    "willothy/minimus",
    priority = 100,
    config = function()
      vim.cmd.colorscheme("minimus")
    end,
    event = "UiEnter",
    -- dir = "~/projects/lua/minimus/",
  },
  {
    "rktjmp/lush.nvim",
    cmd = "Lushify",
  },
  {
    "echasnovski/mini.colors",
    config = true,
    cmd = "Colorscheme",
  },
  {
    "echasnovski/mini.hues",
    config = true,
  },
  {
    "tjdevries/colorbuddy.nvim",
  },
  "loganswartz/polychrome.nvim",
  "folke/tokyonight.nvim",
  "rebelot/kanagawa.nvim",
  "eldritch-theme/eldritch.nvim",
}
