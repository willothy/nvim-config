return {
  -- DEPENDENCIES --
  "folke/neoconf.nvim",
  "kkharji/sqlite.lua",
  "nvim-lua/plenary.nvim",
  {
    "nvim-neotest/nvim-nio",
    name = "nio",
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
    event = "VeryLazy",
  },
  -- EDITING --
  {
    "smoka7/multicursors.nvim",
    config = function()
      require("configs.editor.multicursor")
    end,
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("configs.editor.comment")
    end,
    event = "VeryLazy",
  },
  {
    "cshuaimin/ssr.nvim",
    config = function()
      require("configs.editor.ssr")
    end,
  },
  {
    "nvim-pack/nvim-spectre",
    config = true,
  },
  {
    "willothy/moveline.nvim",
    branch = "oxi",
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
      "IndianBoy42/tree-sitter-just",
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
    "nvim-neorg/neorg",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = ":Neorg sync-parsers",
    cmd = "Neorg",
    ft = "norg",
    config = function()
      require("configs.editor.neorg")
    end,
    enabled = false, -- TODO: investigate startup performance
  },
  -- DEFAULT FEATURE EXTENSIONS --
  {
    "gbprod/yanky.nvim",
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
    event = "VeryLazy",
    dependencies = {
      "nvim-telescope/telescope-file-browser.nvim",
      "molecule-man/telescope-menufacture",
      "crispgm/telescope-heading.nvim",
      "debugloop/telescope-undo.nvim",
      "dhruvmanila/browser-bookmarks.nvim",
      "nvim-telescope/telescope-frecency.nvim",
      "nvim-telescope/telescope-smart-history.nvim",
    },
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
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
    },
    config = function()
      require("configs.projects.resession")
    end,
    event = "UiEnter",
  },
  {
    "ahmedkhalf/project.nvim",
    name = "project_nvim",
    event = "VeryLazy",
    config = function()
      require("configs.projects.project")
    end,
  },
  {
    "tiagovla/scope.nvim",
    config = true,
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
    config = true,
    cmd = "WeztermSpawn",
  },
  {
    "desdic/greyjoy.nvim",
    cmd = "Greyjoy",
    config = function()
      require("configs.terminal.greyjoy")
    end,
  },
  {
    "stevearc/overseer.nvim",
    config = function()
      require("configs.editor.overseer")
    end,
    event = "VeryLazy",
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
    event = "VeryLazy",
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    -- "willothy/harpoon",
    -- branch = "combined-ext",
    -- dir = "~/projects/lua/harpoon/",
    event = "VeryLazy",
    config = function()
      require("configs.navigation.harpoon")
    end,
    -- enabled = false,
  },
  {
    "willothy/wrangler.nvim",
    config = true,
    event = "VeryLazy",
    keys = {
      {
        "<C-m>",
        function()
          require("wrangler").toggle_menu()
        end,
        desc = "wrangler: toggle menu",
      },
      {
        "<leader>mw",
        function()
          require("wrangler").toggle_mark()
        end,
        desc = "wrangler: toggle mark",
      },
    },
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
    "SUSTech-data/wildfire.nvim",
    opts = {
      keymaps = {
        init_selection = false,
        node_incremental = false,
        node_decremental = false,
      },
    },
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
  {
    "echasnovski/mini.trailspace",
    config = true,
    event = "VeryLazy",
  },
  {
    "chomosuke/term-edit.nvim",
    opts = {
      prompt_end = "✦ -> ",
    },
    event = "TermOpen",
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
    event = "VeryLazy",
  },
  {
    "tris203/precognition.nvim",
    opts = {},
    -- dir = "~/projects/lua/precognition.nvim/",
  },
  {
    "echasnovski/mini.clue",
    enabled = false,
    config = function()
      require("configs.editor.miniclue")
    end,
    event = "VeryLazy",
  },
}
