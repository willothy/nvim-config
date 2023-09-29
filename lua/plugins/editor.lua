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
    -- cmd = { "Norm", "Reg", "Visual" },
    event = "User ExtraLazy",
  },
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
    -- event = "VeryLazy",
    config = function()
      require("configs.editor.treesitter")
    end,
  },
  {
    "chrisgrieser/nvim-various-textobjs",
    config = true,
  },
  {
    -- "folke/which-key.nvim",
    "willothy/which-key.nvim",
    -- branch = "description-sort",
    -- dir = "~/projects/lua/which-key.nvim/",
    config = function()
      require("configs.editor.which-key")
    end,
    event = "User ExtraLazy",
  },
  {
    "mrjones2014/legendary.nvim",
    -- cmd = "Legendary",
    event = "User ExtraLazy",
    config = function()
      require("configs.editor.legendary")
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      require("configs.editor.telescope")
    end,
    event = "User ExtraLazy",
    dependencies = {
      "nvim-telescope/telescope-file-browser.nvim",
      "molecule-man/telescope-menufacture",
      "crispgm/telescope-heading.nvim",
      "debugloop/telescope-undo.nvim",
      "dhruvmanila/browser-bookmarks.nvim",
      {
        -- "nvim-telescope/telescope-frecency.nvim",
        -- commit = "fbda5d91d6e787f5977787fa4a81da5c8e22160a",
        "willothy/telescope-frecency.nvim",
        branch = "fix-workspaces",
        -- dir = "~/projects/lua/telescope-frecency.nvim",
      },
      "nvim-telescope/telescope-smart-history.nvim",
    },
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  },
  {
    "willothy/savior.nvim",
    config = true,
    event = { "InsertEnter", "TextChanged" },
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
    -- "echasnovski/mini.files",
    "willothy/mini.files",
    config = function()
      require("configs.editor.mini-files")
    end,
    event = "CmdlineEnter",
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
    "akinsho/toggleterm.nvim",
    event = "CmdlineEnter",
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
    event = "CmdlineEnter",
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
    "LeonHeidelbach/trailblazer.nvim",
    config = function()
      require("configs.navigation.trailblazer")
    end,
    event = "User ExtraLazy",
  },
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
    event = "CmdlineEnter",
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
    -- cmd = "ReachOpen",
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
    -- cmd = "DiffviewOpen",
    event = "CmdlineEnter",
  },
  {
    "akinsho/git-conflict.nvim",
    config = function()
      require("configs.git.git-conflict")
    end,
    event = "User ExtraLazy",
  },
  {
    "NeogitOrg/neogit",
    event = "CmdlineEnter",
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
  {
    "chomosuke/term-edit.nvim",
    opts = {
      prompt_end = "✦ -> ",
    },
    event = "TermOpen",
  },
}
