return {
  {
    "aznhe21/actions-preview.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("configs.lsp.actions-preview")
    end,
  },
  {
    "j-hui/fidget.nvim",
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
    ft = "rust",
    config = function()
      require("configs.lsp.rust-tools")
    end,
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
    config = function()
      require("configs.lsp.lightbulb")
    end,
    enabled = false,
    event = "LspAttach",
  },
}
