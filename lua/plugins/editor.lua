return {
  -- COMMANDS --
  {
    "smjonas/live-command.nvim",
    config = true,
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
    "gbprod/substitute.nvim",
    opts = {
      yank_substituted_text = true,
    },
    event = "VeryLazy",
  },
  -- TREESITTER --
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    build = ":TSUpdate",
    -- commit = "9e1cda4e71a763ba1f1ac099498c7ce40edc6dd2",
    dependencies = {
      -- "nvim-treesitter/nvim-treesitter-textobjects",
      -- "IndianBoy42/tree-sitter-just",
      "chrisgrieser/nvim-various-textobjs",
    },
    config = function()
      require("configs.editor.treesitter")
      -- pcall(vim.treesitter.start)
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
  -- DEFAULT FEATURE EXTENSIONS --
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("snacks").setup({
        -- dashboard = {
        --   sections = {
        --     { section = "startup" },
        --   },
        -- },
        terminal = {},
        notifier = {
          enabled = true,
          style = "compact",
          notification = {
            bo = {
              filetype = "markdown",
            },
          },
          -- style = "notification",
          -- style = {
          --   ft = "markdown",
          --   bo = {
          --     filetype = "markdown",
          --   },
          --   wo = {
          --     conceallevel = 3,
          --   },
          -- },
        },
        words = {},
        indent = {
          enabled = true,
          indent = {
            char = "▏",
            hl = "IndentScope",
          },
          scope = {
            char = "▏",
            hl = "Function",
            only_current = true,
          },
        },
      })
    end,
  },
  {
    "gbprod/yanky.nvim",
    dependencies = {
      "kkharji/sqlite.lua",
    },
    event = "VeryLazy",
    opts = {
      ring = { storage = "sqlite" },
    },
  },
  {
    "utilyre/sentiment.nvim",
    event = "VeryLazy",
    config = true,
  },
  -- FILE MANAGERS & FUZZY FINDERS --
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      require("configs.editor.telescope")
    end,
    cmd = "Telescope",
    dependencies = {
      "dhruvmanila/browser-bookmarks.nvim",
      "nvim-telescope/telescope-frecency.nvim",
      --"nvim-telescope/telescope-smart-history.nvim", -- cool but causes sqlite error atm
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
  },
  {
    "stevearc/oil.nvim",
    config = function()
      require("configs.editor.oil")
    end,
    cmd = "Oil",
  },
  {
    "echasnovski/mini.visits",
    config = true,
    event = "VeryLazy",
  },
  -- SESSIONS / PROJECTS --
  {
    "stevearc/resession.nvim",
    dependencies = {
      {
        "tiagovla/scope.nvim",
        config = true,
        event = "VeryLazy",
      },
      "stevearc/oil.nvim",
    },
    config = function()
      require("willothy.sessions")
    end,
    event = "UiEnter",
  },
  {
    -- "ahmedkhalf/project.nvim",
    "DrKJeff16/project.nvim",
    name = "project_nvim",
    event = "VeryLazy",
    opts = {
      detection_methods = {
        "lsp",
        "pattern",
      },
      patterns = {
        ".git",
        "package.json",
        "Cargo.toml",
        "Makefile",
      },
      exclude_dirs = {
        "~/.local/",
        "~/.cargo/",
      },
      ignore_lsp = { "savior", "copilot" },
      silent_chdir = true,
      show_hidden = true,
      scope_chdir = "tab",
    },
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
    -- dir = "~/projects/lua/flatten.nvim/",
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
  },
  {
    "chrisgrieser/nvim-spider",
    config = true,
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
    "tris203/precognition.nvim",
    opts = {
      startVisible = false,
      showBlankVirtLine = false,
    },
    event = "VeryLazy",
  },
  {
    "johmsalas/text-case.nvim",
    opts = {
      default_keymappings_enabled = false,
    },
  },
}
