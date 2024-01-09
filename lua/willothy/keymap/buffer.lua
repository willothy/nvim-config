local keymap = willothy.keymap
-- selene: allow(unused_variable)
local bind, modes = keymap.bind, keymap.modes

local wk = require("which-key")

wk.register({
  name = "buffer",
  r = {
    function()
      require("reach").buffers({
        show_current = true,
        filter = function(buf)
          return true
        end,
        auto_exclude_handles = {
          "0",
          "1",
          "2",
          "3",
          "4",
          "5",
          "6",
          "7",
          "8",
          "9",
        },
      })
    end,
    "reach: buffers",
  },
  s = {
    function()
      require("dropbar.api").pick(vim.v.count ~= 0 and vim.v.count)
    end,
    "dropbar: open",
  },
  b = {
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
    "delete",
  },
  n = {
    function()
      require("cokeline.mappings").by_step("focus", 1)
    end,
    "next",
  },
  p = {
    function()
      require("cokeline.mappings").by_step("focus", -1)
    end,
    "prev",
  },
}, { mode = modes.non_editing, prefix = "<leader>b" })
