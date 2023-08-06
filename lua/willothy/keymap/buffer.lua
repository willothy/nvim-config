local keymap = require("willothy.util.keymap")
-- selene: allow(unused_variable)
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

register({
  r = {
    function()
      require("reach").buffers()
    end,
    "reach: buffers",
  },
  s = {
    function()
      if vim.v.count == 0 then
        require("dropbar.api").pick()
      else
        require("dropbar.api").pick(vim.v.count)
      end
    end,
    "dropbar: open",
  },
  p = {
    function()
      require("cokeline.mappings").pick("focus")
    end,
    "pick & focus",
  },
  x = {
    function()
      require("cokeline.mappings").pick("close")
    end,
    "pick & close",
  },
  Q = {
    function()
      require("bufdelete").bufdelete(vim.v.count)
    end,
    "close current",
  },
}, modes.non_editing, "<leader>b")
