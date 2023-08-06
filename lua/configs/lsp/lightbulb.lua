require("nvim-lightbulb").setup({
  ignore = {
    ft = {
      "harpoon",
      "noice",
      "neo-tree",
      "SidebarNvim",
      "Trouble",
      "terminal",
    },
    -- clients = { "null-ls" },
  },
  autocmd = {
    enabled = true,
    -- updatetime = -1,
  },
  sign = {
    enabled = false,
  },
  float = {
    enabled = true,
    text = "",
    hl = "DiagnosticInfo",
    win_opts = {
      winblend = 100,
      focusable = false,
      anchor = "NE",
    },
  },
})
