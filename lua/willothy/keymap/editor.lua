local keymap = require("willothy.util.keymap")
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

register({
  ["<C-F>"] = {
    bind("ssr", "open"),
    "Structural Search/Replace",
  },
  ["<C-CR>"] = {
    bind("cokeline.mappings", "pick", "focus"),
    "Pick buffer",
  },
  g = {
    -- name = "goto",
    r = {
      bind("glance", "open", "references"),
      "references",
    },
    d = {
      bind("glance", "open", "definitions"),
      "definitions",
    },
    D = {
      vim.lsp.buf.declaration,
      "declaration",
    },
    T = {
      bind("glance", "open", "type_definitions"),
      "type definition",
    },
    i = {
      bind("glance", "open", "implementations"),
      "implementations",
    },
  },
  K = bind("rust-tools.hover_actions", "hover_actions"),
}, modes.non_editing)

register({
  ["<F1>"] = {
    bind("cokeline.mappings", "pick", "focus"),
    "Pick buffer",
  },
  ["<C-Enter>"] = { bind("willothy.terminals", "toggle"), "terminal: toggle" },
  ["<C-e>"] = { bind("harpoon.ui", "toggle_quick_menu"), "harpoon: toggle" },
  ["<M-k>"] = {
    bind("moveline", "up"),
    "move: up",
  },
  ["<M-j>"] = { bind("moveline", "down"), "move: down" },
  ["<C-s>"] = {
    vim.cmd.write,
    "Save",
  },
}, modes.non_editing + modes.insert)

register({
  m = {
    bind("reach", "marks"),
    "marks",
  },
}, modes.non_editing, "<leader>")
