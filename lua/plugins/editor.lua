return {
  "folke/neoconf.nvim",
  "anuvyklack/hydra.nvim",
  "kkharji/sqlite.lua",
  "nvim-lua/plenary.nvim",
  {
    "lukas-reineke/headlines.nvim",
    config = function()
      require("configs.editor.headlines")
    end,
    ft = { "markdown", "help" },
  },
  {
    "smjonas/live-command.nvim",
    config = function()
      require("configs.editor.live_cmd")
    end,
    cmd = { "Norm", "Reg", "Visual" },
  },
  {
    "smoka7/multicursors.nvim",
    config = function()
      require("configs.editor.multicursor")
    end,
    cmd = {
      "MCvisualPattern",
      "MCpattern",
      "MCstart",
      "MCvisual",
      "MCunderCursor",
      "MCclear",
    },
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("configs.editor.comment")
    end,
    event = "User ExtraLazy",
  },
  {
    "cshuaimin/ssr.nvim",
    config = function()
      require("configs.editor.ssr")
    end,
  },
  {
    "folke/trouble.nvim",
    config = function()
      require("configs.editor.trouble")
    end,
  },
  {
    "nvim-pack/nvim-spectre",
    config = true,
  },
  {
    "sourcegraph/sg.nvim",
    config = function()
      require("configs.lsp.sourcegraph")
    end,
    event = "User ExtraLazy",
    build = "nvim -l build/init.lua",
  },
  {
    "willothy/moveline.nvim",
    branch = "oxi",
    event = "User ExtraLazy",
    build = "make build",
  },
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "hrsh7th/nvim-cmp",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "markdown", "help" },
    config = function()
      require("configs.editor.otter")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "IndianBoy42/tree-sitter-just",
      "chrisgrieser/nvim-various-textobjs",
    },
    event = "VeryLazy",
    config = function()
      require("configs.editor.treesitter")
    end,
  },
  {
    "chrisgrieser/nvim-various-textobjs",
    config = true,
  },
  {
    "willothy/which-key.nvim",
    -- branch = "helix",
    branch = "description-sort",
    config = function()
      require("configs.editor.which-key")
    end,
    event = "VeryLazy",
  },
  {
    "mrjones2014/legendary.nvim",
    cmd = "Legendary",
    config = function()
      require("configs.editor.legendary")
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      require("configs.editor.telescope")
    end,
    dependencies = {
      "nvim-telescope/telescope-file-browser.nvim",
      "molecule-man/telescope-menufacture",
      "crispgm/telescope-heading.nvim",
      "debugloop/telescope-undo.nvim",
      "dhruvmanila/browser-bookmarks.nvim",
      "nvim-telescope/telescope-frecency.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-smart-history.nvim",
      -- "nvim-telescope/telescope-fzf-writer.nvim", -- cool but currently broken
    },
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  },
  {
    "willothy/savior.nvim",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "gbprod/yanky.nvim",
    event = "User ExtraLazy",
    config = function()
      require("configs.editor.yanky")
    end,
  },
  {
    "willothy/marks.nvim",
    event = "User ExtraLazy",
    opts = {
      refresh_interval = 1000,
    },
  },
  {
    "echasnovski/mini.files",
    config = function()
      require("configs.editor.mini-files")
    end,
  },
  -- SESSIONS / PROJECTS --
  {
    "stevearc/resession.nvim",
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
  -- TERMINAL --
  {
    "willothy/toggleterm.nvim",
    -- "akinsho/toggleterm.nvim",
    cmd = {
      "ToggleTerm",
      "ToggleTermSendVisualLines",
      "ToggleTermToggleAll",
      "ToggleTermSetName",
      "ToggleTermSendVisualSelection",
      "ToggleTermSendCurrentLine",
    },
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
    -- event = "User ExtraLazy",
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
    event = "User ExtraLazy",
  },
  -- NAVIGATION --
  {
    "folke/flash.nvim",
    config = function()
      require("configs.navigation.flash")
    end,
    event = "User ExtraLazy",
  },
  {
    -- "ThePrimeagen/harpoon",
    "willothy/harpoon", -- harpoon fork with toggleterm integration
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
    "SUSTech-data/wildfire.nvim",
    event = "User ExtraLazy",
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
  },
  {
    "sindrets/diffview.nvim",
    config = true,
    cmd = {
      "DiffviewClose",
      "DiffviewFocusFiles",
      "DiffviewLog",
      "DiffviewRefresh",
      "DiffviewToggleFiles",
      "DiffviewFileHistory",
      "DiffviewOpen",
    },
  },
  {
    "akinsho/git-conflict.nvim",
    config = function()
      require("configs.git.git-conflict")
    end,
    cmd = {
      "GitConflictPrevConflict",
      "GitConflictNextConflict",
      "GitConflictChooseNone",
      "GitConflictChooseBase",
      "GitConflictChooseTheirs",
      "GitConflictChooseOurs",
      "GitConflictListQf",
      "GitConflictRefresh",
      "GitConflictChooseBoth",
    },
  },
  {
    "NeogitOrg/neogit",
    -- "cristiansofronie/neogit", -- neogit/neogit#803
    -- branch = "fix_garbage_printing",
    cmd = "Neogit",
    config = function()
      require("configs.git.neogit")
    end,
  },
  {
    "linrongbin16/gitlinker.nvim",
    config = function()
      require("configs.git.gitlinker")
    end,
  },
  {
    "echasnovski/mini.trailspace",
    config = true,
    event = "User ExtraLazy",
  },
}
