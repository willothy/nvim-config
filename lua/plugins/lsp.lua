return {
  -- DEVELOPMENT & TESTING --
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
    branch = "feat/use-external-nio",
    config = function()
      require("configs.editor.neotest")
    end,
    dependencies = {
      "rouge8/neotest-rust",
      "nvim-neotest/neotest-plenary",
    },
    event = "VeryLazy",
  },
  -- LSP UI --
  {
    "j-hui/fidget.nvim",
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
  -- LANGUAGE SERVERS & RELATED TOOLS --
  {
    "williamboman/mason.nvim",
    event = "VeryLazy",
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
    "sourcegraph/sg.nvim",
    config = function()
      require("configs.lsp.sourcegraph")
    end,
    cmd = {
      "CodyDo",
      "CodyTask",
      "CodyAsk",
      "CodyChat",
      "CodyToggle",
      "SourcegraphSearch",
      "SourcegraphLink",
    },
    event = "VeryLazy",
    -- build = "nvim -l build/init.lua",
  },
  {
    -- "garymjr/nvim-snippets",
    "willothy/nvim-snippets",
    config = true,
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    -- dir = "~/projects/lua/nvim-snippets/",
  },
  {
    -- "simrat39/rust-tools.nvim",
    "willothy/rust-tools.nvim",
    branch = "master",
  },
  {
    "p00f/clangd_extensions.nvim",
    config = true,
    event = "LspAttach",
  },
  -- DIAGNOSTICS & FORMATTING --
  {
    "nvimtools/none-ls.nvim",
    config = function()
      require("configs.lsp.null-ls")
    end,
    event = "VeryLazy",
  },
  {
    "stevearc/conform.nvim",
    config = function()
      require("configs.lsp.conform")
    end,
    event = "VeryLazy",
  },
  {
    "mfussenegger/nvim-lint",
    config = function()
      require("configs.lsp.nvim-lint")
    end,
    event = "DiagnosticChanged",
  },
  {
    "dgagn/diagflow.nvim",
    -- "willothy/diagflow.nvim",
    config = function()
      require("configs.lsp.diagflow")
    end,
    event = "VeryLazy",
  },
  -- COMPLETION --
  {
    "hrsh7th/nvim-cmp",
    -- "willothy/nvim-cmp",
    -- dir = "~/projects/lua/nvim-cmp/",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp",
      "dmitmel/cmp-cmdline-history",
      "rcarriga/cmp-dap",
      "zbirenbaum/copilot-cmp",
      "petertriho/cmp-git",
    },
    event = { "CmdlineEnter", "InsertEnter" },
    config = function()
      require("configs.editor.cmp")
    end,
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      require("configs.editor.autopairs")
    end,
    event = "InsertEnter",
  },
  {
    "windwp/nvim-ts-autotag",
    config = true,
    event = "InsertEnter",
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
  -- DEBUGGING --
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
