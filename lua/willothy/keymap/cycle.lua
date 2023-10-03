local keymap = willothy.keymap
local bind, modes = keymap.bind, keymap.modes

local wk = require("which-key")

wk.register({
  name = "previous",
  b = {
    function()
      require("cokeline.mappings").by_step("focus", -vim.v.count1)
    end,
    "buffer",
  },
  t = bind(willothy.utils.tabpage, "switch_by_step", -1):with_desc("tab"),
  e = bind("vim.diagnostic", "goto_prev", { severity = "error" }):with_desc(
    "error"
  ),
  m = bind("marks", "prev"):with_desc("mark"),
  d = bind("vim.diagnostic", "goto_prev"):with_desc("diagnostic"),
}, { mode = modes.normal, prefix = "[" })

wk.register({
  name = "next",
  b = {
    function()
      require("cokeline.mappings").by_step("focus", vim.v.count1)
    end,
    "buffer",
  },
  t = bind(willothy.utils.tabpage, "switch_by_step", 1):with_desc("tab"),
  e = bind("vim.diagnostic", "goto_next", { severity = "error" }):with_desc(
    "error"
  ),
  m = bind("marks", "next"):with_desc("mark"),
  d = bind("vim.diagnostic", "goto_next"):with_desc("diagnostic"),
}, { mode = modes.normal, prefix = "]" })
