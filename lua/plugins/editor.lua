return {
  {
    "zdcthomas/yop.nvim",
    config = true,
  },
  {
    "lukas-reineke/headlines.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true,
    ft = { "markdown", "help", "txt" },
  },
  {
    "anuvyklack/hydra.nvim",
    event = "User ExtraLazy",
  },
  {
    "willothy/hollywood.nvim",
    event = "LspAttach",
    -- dir = "~/projects/lua/hollywood.nvim",
  },
  {
    "VidocqH/lsp-lens.nvim",
    config = true,
    event = "LspAttach",
    enabled = false,
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
    event = "DiagnosticChanged",
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
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "rouge8/neotest-rust",
    },
    event = "LspAttach",
    config = function()
      require("configs.editor.neotest")
    end,
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
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "molecule-man/telescope-menufacture",
      "crispgm/telescope-heading.nvim",
      "debugloop/telescope-undo.nvim",
      "dhruvmanila/browser-bookmarks.nvim",
      "nvim-telescope/telescope-frecency.nvim",
    },
    cmd = "Telescope",
    -- event = "User ExtraLazy",
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  },
  {
    "stevearc/resession.nvim",
    dependencies = {
      "tiagovla/scope.nvim",
    },
    config = function()
      require("configs.projects.resession")
    end,
    event = "User ExtraLazy",
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
  {
    "willothy/savior.nvim",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "pynappo/tabnames.nvim",
    enabled = false,
    event = "User ExtraLazy",
    config = function()
      require("configs.projects.tabnames")
    end,
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
  -- {
  --   "tomiis4/BufEx.nvim",
  --   lazy = false,
  --   config = true,
  -- },
}
