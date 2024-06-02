return {
  {
    -- "folke/neoconf.nvim",
    "willothy/neoconf.nvim",
    branch = "0.10-deprecations",
    config = true,
    -- event = "VimEnter",
  },
  {
    -- "anuvyklack/hydra.nvim" -- original author
    -- "nvimtools/hydra.nvim", -- active fork
    "willothy/hydra.nvim",
    -- dir = "~/projects/lua/hydra.nvim/",
  },
  -- COMMANDS --
  {
    "smjonas/live-command.nvim",
    config = function()
      require("configs.editor.live_cmd")
    end,
    cmd = "Norm",
  },
  -- EDITING --
  {
    "numToStr/Comment.nvim",
    config = function()
      require("configs.editor.comment")
    end,
    event = "VeryLazy",
  },
  {
    "nvim-pack/nvim-spectre",
    opts = {
      is_block_ui_break = true,
    },
  },
  {
    "willothy/moveline.nvim",
    -- branch = "oxi",
    event = "VeryLazy",
    build = "make build",
  },
  {
    "gbprod/substitute.nvim",
    opts = {
      yank_substituted_text = true,
    },
    event = "VeryLazy",
  },
  -- TREESITTER --
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      -- "IndianBoy42/tree-sitter-just",
      "chrisgrieser/nvim-various-textobjs",
    },
    config = function()
      require("configs.editor.treesitter")
    end,
  },
  {
    "lukas-reineke/headlines.nvim",
    ft = "markdown",
    config = function()
      require("configs.editor.headlines")
    end,
  },
  {
    "jmbuhr/otter.nvim",
    ft = "markdown",
    config = function()
      require("configs.editor.otter")
    end,
  },
  {
    "folke/todo-comments.nvim",
    config = true,
    event = "VeryLazy",
  },
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = function()
      require("luarocks-nvim").setup({
        rocks = {
          "magick",
        },
      })
    end,
    event = "VeryLazy",
  },
  {
    "nvim-neorg/neorg",
    dependencies = {
      "pysan3/pathlib.nvim",
      "nvim-lua/plenary.nvim",
      "vhyrro/luarocks.nvim",
      "nvim-neorg/lua-utils.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = "Neorg",
    ft = "norg",
    config = function()
      require("configs.editor.neorg")
    end,
  },
  -- DEFAULT FEATURE EXTENSIONS --
  {
    "gbprod/yanky.nvim",
    dependencies = {
      "kkharji/sqlite.lua",
    },
    -- commit = "590a713b0372485f595eea36e7e3ab2069946794",
    event = "VeryLazy",
    config = function()
      require("configs.editor.yanky")
    end,
  },
  {
    "willothy/marks.nvim",
    event = "VeryLazy",
    opts = {
      refresh_interval = 1000,
    },
  },
  {
    "nacro90/numb.nvim",
    config = true,
    event = "CmdlineEnter",
  },
  {
    "utilyre/sentiment.nvim",
    event = "VeryLazy",
    opts = {
      delay = 30,
      pairs = {
        { "(", ")" },
        { "{", "}" },
        { "[", "]" },
      },
    },
  },
  -- FILE MANAGERS & FUZZY FINDERS --
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      require("configs.editor.telescope")
    end,
    -- event = "VeryLazy",
    cmd = "Telescope",
    dependencies = {
      "nvim-telescope/telescope-file-browser.nvim",
      "dhruvmanila/browser-bookmarks.nvim",
      "nvim-telescope/telescope-frecency.nvim",
      --"nvim-telescope/telescope-smart-history.nvim", -- cool but causes sqlite error atm
      "polirritmico/telescope-lazy-plugins.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
  },
  {
    "stevearc/oil.nvim",
    -- "willothy/oil.nvim",
    -- branch = "feat-select-win",
    -- dir = "~/projects/lua/oil.nvim/",
    config = function()
      require("configs.editor.oil")
    end,
    cmd = "Oil",
  },
  {
    "echasnovski/mini.files",
    -- "willothy/mini.files",
    config = function()
      require("configs.editor.mini-files")
    end,
    cmd = "MiniFiles",
  },
  {
    "echasnovski/mini.visits",
    config = true,
    event = "VeryLazy",
  },
  -- SESSIONS / PROJECTS --
  {
    "stevearc/resession.nvim",
    -- dir = "~/projects/lua/resession.nvim/",
    dependencies = {
      "tiagovla/scope.nvim",
      "stevearc/oil.nvim",
    },
    config = function()
      require("configs.projects.resession")
    end,
    event = "UiEnter",
  },
  {
    -- "ahmedkhalf/project.nvim",
    "LennyPhoenix/project.nvim",
    branch = "fix-get_clients",
    name = "project_nvim",
    event = "VeryLazy",
    config = function()
      require("configs.projects.project")
    end,
  },
  {
    "tiagovla/scope.nvim",
    config = true,
    event = "VeryLazy",
  },
  {
    "willothy/savior.nvim",
    config = true,
    event = { "InsertEnter", "TextChanged" },
  },
  -- TERMINAL --
  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    -- dir = "~/projects/lua/toggleterm.nvim/",
    config = function()
      require("configs.terminal.toggleterm")
    end,
  },
  {
    "willothy/flatten.nvim",
    branch = "guest-data",
    -- dir = "~/projects/lua/flatten/",
    -- cond = true,
    lazy = false,
    priority = 1000,
    config = function()
      require("configs.terminal.flatten")
    end,
  },
  {
    "willothy/wezterm.nvim",
    -- dir = "~/projects/lua/wezterm.nvim/",
    config = function()
      require("configs.editor.wezterm")
    end,
    cmd = { "Wezterm" },
  },
  {
    "stevearc/overseer.nvim",
    config = function()
      require("configs.editor.overseer")
    end,
    cmd = {
      "OverseerRun",
      "OverseerRunCmd",
      "OverseerRunOpen",
      "OverseerRunToggle",
    },
  },
  -- NAVIGATION --
  -- {
  --   "LeonHeidelbach/trailblazer.nvim",
  --   config = function()
  --     require("configs.navigation.trailblazer")
  --   end,
  --   event = "VeryLazy",
  -- },
  {
    "folke/flash.nvim",
    config = function()
      require("configs.navigation.flash")
    end,
    keys = {
      { "f", desc = "flash" },
      { "F", desc = "flash" },
      { "t", desc = "flash" },
      { "T", desc = "flash" },
    },
    -- event = "VeryLazy",
  },
  {
    "ThePrimeagen/harpoon",
    commit = "a38be6e0dd4c6db66997deab71fc4453ace97f9c",
    branch = "harpoon2",
    -- "willothy/harpoon",
    -- dir = "~/projects/lua/harpoon/",
    config = function()
      require("configs.navigation.harpoon")
    end,
  },
  {
    "cbochs/portal.nvim",
    config = function()
      require("configs.navigation.portal")
    end,
    cmd = "Portal",
  },
  {
    "chrisgrieser/nvim-spider",
    config = true,
  },
  {
    "toppair/reach.nvim",
    config = function()
      require("configs.editor.reach")
    end,
    cmd = "ReachOpen",
  },
  {
    "abecodes/tabout.nvim",
    dependencies = {
      "hrsh7th/nvim-cmp",
    },
    opts = {
      tabkey = "",
      backwards_tabkey = "",
      act_as_tab = true,
      ignore_beginning = true,
      act_as_shift_tab = false,
      default_tab = "",
      default_shift_tab = "",
    },
  },
  -- GIT --
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("configs.git.gitsigns")
    end,
    event = "VeryLazy",
  },
  {
    "sindrets/diffview.nvim",
    config = true,
    cmd = {
      "DiffviewOpen",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
  },
  {
    "akinsho/git-conflict.nvim",
    config = function()
      require("configs.git.git-conflict")
    end,
    event = "VeryLazy",
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    config = function()
      require("configs.git.neogit")
    end,
  },
  {
    "linrongbin16/gitlinker.nvim",
    opts = {
      message = true,
    },
    cmd = "GitLink",
  },
  -- MISC --
  {
    "echasnovski/mini.trailspace",
    config = true,
    event = { "TextChanged", "TextChangedI" },
  },
  {
    "chomosuke/term-edit.nvim",
    opts = {
      prompt_end = "-> ",
    },
    event = "TermEnter",
  },
  {
    "LhKipp/nvim-nu",
    config = true,
    ft = "nu",
  },
  {
    "tris203/hawtkeys.nvim",
    -- dir = "~/projects/lua/hawtkeys.nvim/",
    config = function()
      require("configs.editor.hawtkeys")
    end,
    cmd = "Hawtkeys",
  },
  {
    "tris203/precognition.nvim",
    opts = {
      startVisible = false,
      showBlankVirtLine = false,
    },
    event = "VeryLazy",
    -- dir = "~/projects/lua/precognition.nvim/",
  },
  {
    "johmsalas/text-case.nvim",
    opts = {
      default_keymappings_enabled = false,
    },
  },
}
