local icons = require("willothy.icons")

require("lightbulb").setup({
  ignore = {
    ft = {
      "harpoon",
      "noice",
      "neo-tree",
      "SidebarNvim",
      "Trouble",
      "terminal",
    },
    clients = { "null-ls" },
  },
  autocmd = {
    enabled = true,
    updatetime = -1,
  },
  sign = {
    enabled = true,
    priority = 100,
    hl = "DiagnosticSignWarn",
    text = icons.lsp.action_hint,
  },
})
