local spider = function(motion)
  return {
    motion,
    function()
      require("spider").motion(motion)
    end,
    desc = "which_key_ignore",
    mode = { "n", "o", "x" },
  }
end
return {
  {
    "lukas-reineke/headlines.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true,
    ft = { "markdown", "help", "txt" },
  },
  {
    "anuvyklack/hydra.nvim",
  },
  {
    "willothy/hollywood.nvim",
    event = "LspAttach",
    -- dir = "~/projects/lua/hollywood.nvim",
  },
  {
    "ThePrimeagen/refactoring.nvim",
    config = true,
    event = "LspAttach",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "folke/neodev.nvim",
    config = true,
  },
  {
    "smjonas/live-command.nvim",
    cmd = { "Norm", "Visual", "Reg" },
    config = function()
      require("configs.editor.live_cmd")
    end,
  },
  {
    "smoka7/multicursors.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "anuvyklack/hydra.nvim",
    },
    config = function()
      require("configs.editor.multicursor")
    end,
    cmd = {
      "MCstart",
      "MCvisual",
      "MCclear",
      "MCpattern",
      "MCvisualPattern",
      "MCunderCursor",
    },
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
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    config = function()
      require("configs.editor.trouble")
    end,
  },
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    config = true,
  },
  {
    "sourcegraph/sg.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "SourcegraphLink",
      "SourcegraphSearch",
      "SourcegraphLogin",
      "SourcegraphBuild",
      "CodyExplain",
      "CodyAsk",
      "CodyChat",
      "CodyDo",
      "CodyToggle",
      "CodyHistory",
    },
    config = function()
      require("configs.lsp.sourcegraph")
    end,
    build = "nvim -l build/init.lua",
  },
  {
    "willothy/moveline.nvim",
    branch = "oxi",
    event = "User ExtraLazy",
    -- dir = "~/projects/rust/moveline.nvim/",
    build = "make build",
  },
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "hrsh7th/nvim-cmp",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "markdown", "txt" },
    config = function()
      require("configs.editor.otter")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
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
    branch = "helix",
    -- branch = "custom-views",
    -- dir = "~/projects/lua/which-key.nvim/",
    config = function()
      require("configs.editor.which-key")
    end,
    event = "VeryLazy",
  },
  {
    "mrjones2014/legendary.nvim",
    dependencies = {
      "kkharji/sqlite.lua",
    },
    cmd = "Legendary",
    config = function()
      require("configs.editor.legendary")
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    -- dir = "~/projects/lua/telescope.nvim/",
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
    },
    event = "User ExtraLazy",
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
    event = "VeryLazy",
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
    -- event = "User ExtraLazy",
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
    event = "User ExtraLazy",
  },
  -- TERMINAL --
  {
    "akinsho/toggleterm.nvim",
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
    cmd = "WeztermSpawn",
  },
  {
    "desdic/greyjoy.nvim",
    dependencies = {
      "stevearc/overseer.nvim",
    },
    cmd = "Greyjoy",
    config = function()
      require("configs.terminal.greyjoy")
    end,
  },
  -- NAVIGATION --
  {
    "folke/flash.nvim",
    lazy = true,
    config = function()
      require("configs.navigation.flash")
    end,
  },
  {
    "ThePrimeagen/harpoon",
    config = true,
  },
  {
    "cbochs/portal.nvim",
    config = function()
      require("configs.navigation.portal")
    end,
  },
  {
    "chrisgrieser/nvim-spider",
    keys = {
      spider("w"),
      spider("b"),
      spider("e"),
      spider("ge"),
    },
  },
  {
    "toppair/reach.nvim",
    config = true,
    cmd = "ReachOpen",
  },
  {
    "rhysd/accelerated-jk",
    event = "User ExtraLazy",
  },
  {
    "SUSTech-data/wildfire.nvim",
    config = true,
    keys = {
      { "<CR>" },
      { "<BS>" },
    },
  },
  -- GIT --
  {
    "lewis6991/gitsigns.nvim",
    event = "User ExtraLazy",
    config = function()
      require("configs.git.gitsigns")
    end,
  },
  {
    "sindrets/diffview.nvim",
    cmd = "DiffViewOpen",
    config = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  {
    "akinsho/git-conflict.nvim",
    cmd = { "GitConflict", "GitConflictRefresh" },
    config = function()
      require("configs.git.git-conflict")
    end,
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = "nvim-lua/plenary.nvim",
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
}
