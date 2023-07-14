return {
  -- {
  --   "echasnovski/mini.indentscope",
  --   name = "mini.indentscope",
  --   lazy = true,
  --   enabled = false,
  --   event = "VeryLazy",
  --   config = function()
  --     require("mini.indentscope").setup({
  --       symbol = "▏",
  --       options = {
  --         -- border = "bottom",
  --         try_as_border = true,
  --       },
  --     })
  --   end,
  -- },
  {
    "echasnovski/mini.cursorword",
    name = "mini.cursorword",
    event = "VeryLazy",
    config = function() require("mini.cursorword").setup() end,
  },
  {
    "huy-hng/anyline.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    opts = {
      highlight = "WinSeparator",
      context_highlight = "Function",
      ft_ignore = {
        "NvimTree",
        "TelescopePrompt",
        "Trouble",
        "SidebarNvim",
        "neo-tree",
        "noice",
        "terminal",
      },
    },
  },
}
