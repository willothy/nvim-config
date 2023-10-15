local keymap = willothy.keymap
local modes = keymap.modes

local wk = require("which-key")

vim.keymap.set("t", "<Esc>", vim.cmd.stopinsert, {
  desc = "Exit terminal",
})

wk.register({
  ["<C-Enter>"] = {
    function()
      willothy.term.main:toggle()
    end,
    "terminal: toggle",
  },
  ["<S-Enter>"] = {
    function()
      willothy.term.main:toggle()
    end,
    "terminal: toggle",
  },
}, { mode = modes.non_editing + modes.terminal })
