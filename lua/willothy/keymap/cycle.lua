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
  t = {
    bind("willothy.util.tabpage", "switch_by_step", -1),
    "tab",
  },
  e = {
    function()
      vim.diagnostic.goto_prev({ severity = "error" })
    end,
    "error",
  },
  m = {
    function()
      require("marks").prev()
    end,
    "mark",
  },
  d = {
    vim.diagnostic.goto_prev,
    "diagnostic",
  },
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
  t = {
    bind("willothy.util.tabpage", "switch_by_step", 1),
    "tab",
  },
  e = {
    bind(vim.diagnostic.goto_next, { severity = "error" }),
    "error",
  },
  m = {
    function()
      require("marks").next()
    end,
    "mark",
  },
  d = {
    vim.diagnostic.goto_next,
    "diagnostic",
  },
}, modes.normal, "]")
