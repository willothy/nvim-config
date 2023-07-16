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
    event = { "InsertEnter", "CmdLineEnter" },
    config = function()
      vim.api.nvim_create_autocmd(
        { "User VeryLazy", "BufReadPost", "CursorHold" },
        {
          once = true,
          callback = function() require("copilot").setup(copilot_opt) end,
        }
      )
    end,
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {
      keymaps = {
        insert = false,
        insert_line = false,
        normal = false,
        normal_cur = false,
        normal_line = false,
        normal_cur_line = false,
        visual = "S",
        visual_line = false,
        delete = "dS",
        change = "cS",
      },
    },
  },
}
