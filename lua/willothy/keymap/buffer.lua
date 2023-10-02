local keymap = willothy.keymap
-- selene: allow(unused_variable)
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

register({
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
      if vim.v.count == 0 then
        require("dropbar.api").pick()
      else
        require("dropbar.api").pick(vim.v.count)
      end
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
}, modes.non_editing, "<leader>b")
