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
  },
  {
    "folke/neodev.nvim",
    config = true,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "rouge8/neotest-rust",
    },
    event = "LspAttach",
    config = function()
      require("configs.editor.neotest")
    end,
  },
  {
    "j-hui/fidget.nvim",
    branch = "legacy",
    -- enabled = false,
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
  },
  {
    -- "simrat39/rust-tools.nvim",
    "willothy/rust-tools.nvim",
    -- dir = "~/projects/lua/rust-tools.nvim/",
    branch = "master",
  },
  {
    "p00f/clangd_extensions.nvim",
    config = true,
    event = "LspAttach",
  },
  {
    "williamboman/mason.nvim",
    event = "User ExtraLazy",
    config = true,
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("configs.lsp.lspconfig")
    end,
    event = "VeryLazy",
  },
  {
    "kevinhwang91/nvim-ufo",
    name = "ufo",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    opts = {
      fold_virt_text_handler = vim.F.if_nil,
    },
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      require("configs.lsp.null-ls")
    end,
    event = "User ExtraLazy",
  },
  {
    "dgagn/diagflow.nvim",
    -- "willothy/diagflow.nvim",
    config = function()
      require("configs.lsp.diagflow")
    end,
    event = "User ExtraLazy",
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
      "petertriho/cmp-git",

      -- Snippetsrequire\("cmp
      "L3MON4D3/LuaSnip",
    },
    event = { "User ExtraLazy", "InsertEnter" },
    config = function()
      require("configs.editor.cmp")
    end,
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      require("configs.editor.autopairs")
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
      require("configs.editor.copilot")
    end,
  },
  {
    "kylechui/nvim-surround",
    config = true,
    event = "InsertEnter",
  },
  -- DAP --
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      require("configs.debugging.dap")
    end,
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
