return {
  {
    "folke/which-key.nvim",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup({
        plugins = {
          presets = {
            operators = true,
            windows = false,
            nav = true,
            z = true,
            g = true,
          },
        },
        operators = {
          gc = nil,
        },
        key_labels = {
          ["<space>"] = "SPC",
          ["<cr>"] = "RET",
          ["<tab>"] = "TAB",
        },
        window = {
          -- position = "top",
          winblend = 20,
        },
      })
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
    opts = {
      funcs = {},
      autocmds = {},
      commands = {},
      keymaps = {},
      which_key = {
        auto_register = true,
      },
      extensions = {
        nvim_tree = true,
        -- smart_splits = true,
        op_nvim = false,
      },
    },
  },
}
