local keymap = require("willothy.util.keymap")
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

register({
  o = {
    bind("telescope.builtin", "oldfiles"),
    "oldfiles",
  },
  r = {
    bind("telescope.builtin", "registers"),
    "registers",
  },
  s = {
    bind("telescope.builtin", "lsp_document_symbols"),
    "document symbols",
  },
  q = {
    bind("trouble", "open", "quickfix"),
    "quickfix",
  },
  l = {
    bind("trouble", "open", "loclist"),
    "loclist",
  },
  d = {
    bind("dapui", "toggle"),
    "dap ui",
  },
  u = { vim.cmd.UndotreeToggle, "undotree" },
  L = {
    k = {
      bind("Legendary", "keymaps"),
      "keymaps",
    },
    a = {
      bind("Legendary", "autocmds"),
      "autocmds",
    },
    c = {
      bind("Legendary", "commands"),
      "commands",
    },
    f = {
      bind("Legendary", "functions"),
      "functions",
    },
  },
}, modes.non_editing, "<leader>v")
