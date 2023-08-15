local keymap = require("willothy.util.keymap")
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

register({
  name = "previous",
  b = {
    function()
      require("cokeline.mappings").by_step(
        "focus",
        -(vim.v.count >= 1 and vim.v.count or 1)
      )
    end,
    "buffer",
  },
  t = bind("willothy.util.tabpage", "switch_by_step", -1):with_desc("tab"),
  e = bind("vim.diagnostic", "goto_prev", { severity = "error" }):with_desc("error"),
  m = bind("marks", "prev"):with_desc("mark"),
  d = bind("vim.diagnostic", "goto_prev"):with_desc("diagnostic"),
}, modes.normal, "[")

register({
  name = "next",
  b = {
    function()
      require("cokeline.mappings").by_step(
        "focus",
        (vim.v.count >= 1 and vim.v.count or 1)
      )
    end,
    "buffer",
  },
  t = 
    bind("willothy.util.tabpage", "switch_by_step", 1):with_desc("tab"),
  e = bind("vim.diagnostic", "goto_next", { severity = "error" }):with_desc("error"),
  m = bind("marks", "next"):with_desc("mark"),
  d = bind("vim.diagnostic", "goto_next"):with_desc("diagnostic"),
}, modes.normal, "]")
