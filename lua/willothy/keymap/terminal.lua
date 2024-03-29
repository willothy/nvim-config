local keymap = willothy.map
local modes = keymap.modes

local wk = require("which-key")

vim.keymap.set("t", "<Esc>", vim.cmd.stopinsert, {
  desc = "Exit terminal",
})

wk.register({
  ["<S-Enter>"] = {
    function()
      willothy.terminal.main:toggle()
    end,
    "terminal: toggle",
  },
  ["<C-Enter>"] = {
    function()
      require("trouble").toggle({
        mode = "diagnostics",
      })
      -- willothy.terminal.main:toggle()
    end,
    "trouble: toggle",
  },
}, { mode = modes.non_editing + modes.terminal })
