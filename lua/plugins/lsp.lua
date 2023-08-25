return {
  {
    "willothy/hollywood.nvim",
    event = "LspAttach",
    -- dir = "~/projects/lua/hollywood.nvim",
  },
  {
    "aznhe21/actions-preview.nvim",
    config = function()
      require("configs.lsp.actions-preview")
    end,
    event = "LspAttach",
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
    "j-hui/fidget.nvim",
    enabled = false,
    branch = "legacy",
    config = function()
      require("configs.lsp.fidget")
    end,
    event = "LspAttach",
  },
  {
    "smjonas/inc-rename.nvim",
    config = true,
    event = "LspAttach",
  },
  {
    "lukas-reineke/lsp-format.nvim",
    config = true,
    lazy = true,
    event = "LSPAttach",
  },
  {
    -- "simrat39/rust-tools.nvim",
    "willothy/rust-tools.nvim",
    branch = "no-augment",
  },
  {
    "williamboman/mason.nvim",
    event = "VeryLazy",
    opts = {
      PATH = "prepend",
    },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "jay-babu/mason-null-ls.nvim",
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    event = "User ExtraLazy",
    config = function()
      require("configs.lsp.lspconfig")
    end,
  },
  {
    "kevinhwang91/nvim-ufo",
    name = "ufo",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    config = function()
      require("configs.lsp.ufo")
    end,
    event = "User ExtraLazy",
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    lazy = true,
    event = "VeryLazy",
    config = function()
      require("configs.lsp.null-ls")
    end,
  },
  {
    "kosayoda/nvim-lightbulb",
    enabled = false,
    config = function()
      require("configs.lsp.lightbulb")
    end,
    event = "LspAttach",
  },
  {
    "dnlhc/glance.nvim",
    config = function()
      require("configs.lsp.glance")
    end,
    event = "LspAttach",
  },
  {
    "dgagn/diagflow.nvim",
    config = function()
      require("configs.lsp.diagflow")
    end,
    event = "LspAttach",
  },
  -- COMPLETION --
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      -- "FelipeLema/cmp-async-path",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-document-symbol",
      "dmitmel/cmp-cmdline-history",
      "saadparwaiz1/cmp_luasnip",
      "rcarriga/cmp-dap",
      "zbirenbaum/copilot-cmp",

      -- Snippets
      "L3MON4D3/LuaSnip",
    },
    event = { "InsertEnter", "CmdLineEnter" },
    config = function()
      require("configs.editor.cmp")
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "VeryLazy",
    config = function()
      require("configs.editor.autopairs")
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    config = true,
    ft = {
      "html",
      "javascript",
      "javascriptreact",
      "typescriptreact",
      "svelte",
      "vue",
    },
  },
  {
    "zbirenbaum/copilot.lua",
    event = { "InsertEnter", "CmdLineEnter", "VeryLazy" },
    config = function()
      require("configs.editor.copilot")
    end,
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = true,
  },
  -- DAP --
  {
    "mfussenegger/nvim-dap",
    config = function()
      require("configs.debugging.dap")
      require("nvim-dap-virtual-text")
    end,
    -- event = "LspAttach",
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      clear_on_continue = true,
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("configs.debugging.dap-ui")
    end,
  },
  -- Individual debugger plugins
  {
    "jbyuki/one-small-step-for-vimkind",
  },
}
