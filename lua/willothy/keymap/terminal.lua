local keymap = willothy.map
local modes = keymap.modes

local wk = require("which-key")

vim.keymap.set("t", "<Esc>", vim.cmd.stopinsert, {
  desc = "Exit terminal",
})

wk.register({
  ["<C-Enter>"] = {
    function()
      willothy.terminal.main:toggle()
    end,
    "terminal: toggle",
  },
  ["<S-Enter>"] = {
    function()
      willothy.terminal.main:toggle()
    end,
    "terminal: toggle",
  },
}, { mode = modes.non_editing + modes.terminal })
