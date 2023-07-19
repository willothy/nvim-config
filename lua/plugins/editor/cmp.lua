local autopairs = {
  disable_filetype = { "TelescopePrompt" },
}

local copilot_opt = {
  suggestion = {
    enabled = true,
    auto_trigger = false,
    keymap = {},
  },
  panel = {},
}

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

      -- Snippets
      "L3MON4D3/LuaSnip",
    },
    lazy = true,
    event = { "InsertEnter", "CmdLineEnter" },
    config = function() require("willothy.cmp") end,
  },
  {
    "windwp/nvim-autopairs",
    lazy = true,
    event = "VeryLazy",
    opts = autopairs,
  },
  {
    "windwp/nvim-ts-autotag",
    config = true,
    event = "VeryLazy",
  },
  {
    "zbirenbaum/copilot.lua",
    lazy = true,
    event = { "InsertEnter", "CmdLineEnter", "User VeryLazy" },
    config = function() require("copilot").setup(copilot_opt) end,
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = true,
  },
}
