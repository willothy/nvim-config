local keymap = require("willothy.util.keymap")
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

register({
  ["<Esc>"] = { "<C-\\><C-n>", "Exit terminal" },
}, modes.terminal)
