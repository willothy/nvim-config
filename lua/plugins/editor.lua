return {
  {
    "lukas-reineke/headlines.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "anuvyklack/hydra.nvim",
  },
  {
    "willothy/hollywood.nvim",
    dir = "~/projects/lua/hollywood.nvim",
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
    event = "User ExtraLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "folke/neodev.nvim",
    ft = "lua",
    config = function()
      vim.defer_fn(function()
        require("lspconfig")
        vim.cmd.LspStart("lua_ls")
      end, 1000)
    end,
  },
  {
    "smjonas/live-command.nvim",
    cmd = { "Norm", "Reg" },
    config = function()
      require("configs.editor.live_cmd")
    end,
  },
  {
    "mg979/vim-visual-multi",
    event = "User ExtraLazy",
    enabled = false,
    config = function()
      require("configs.editor.visual-multi")
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
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
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
    event = "User ExtraLazy",
    config = function()
      require("configs.lsp.sourcegraph")
    end,
    build = "nvim -l build/init.lua",
  },
  {
    "willothy/moveline.nvim",
    -- dir = '~/projects/neovim/moveline/',
    build = "make",
    event = "VeryLazy",
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "rouge8/neotest-rust",
    },
    lazy = true,
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
    event = "User ExtraLazy",
    config = function()
      require("configs.editor.otter")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    event = "VeryLazy",
    config = function()
      require("configs.editor.treesitter")
    end,
  },
  {
    "willothy/which-key.nvim",
    branch = "description-sort",
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
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Legendary",
    config = function()
      require("configs.editor.legendary")
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "molecule-man/telescope-menufacture",
      "crispgm/telescope-heading.nvim",
      "debugloop/telescope-undo.nvim",
      "dhruvmanila/browser-bookmarks.nvim",
      "nvim-telescope/telescope-frecency.nvim",
    },
    config = function()
      require("configs.editor.telescope")
    end,
    event = "User ExtraLazy",
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  },
  {
    "nvim-telescope/telescope-frecency.nvim",
    dependencies = { "kkharji/sqlite.lua" },
  },
  {
    "stevearc/resession.nvim",
    dependencies = {
      "ahmedkhalf/project.nvim",
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
    event = "User ExtraLazy",
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
}
