return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "FelipeLema/cmp-async-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-document-symbol",
      "dmitmel/cmp-cmdline-history",
      "saadparwaiz1/cmp_luasnip",
      "rcarriga/cmp-dap",

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
}
