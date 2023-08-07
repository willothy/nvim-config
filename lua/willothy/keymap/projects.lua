local keymap = require("willothy.util.keymap")
-- selene: allow(unused_variable)
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

register({
  name = "projects",
  f = {
    function()
      require("willothy.util.fs").browse("~/projects/")
    end,
    "projects",
  },
  v = {
    function()
      require("willothy.util.fs").browse()
    end,
    "current directory",
  },
  r = {
    function()
      require("willothy.util.fs").browse(
        require("willothy.util.fs").project_root()
      )
    end,
    "project root",
  },
  h = {
    function()
      require("willothy.util.fs").browse(vim.loop.os_homedir())
    end,
    "home directory",
  },
  n = {
    function()
      require("willothy.util.fs").browse(vim.fn.stdpath("config"))
    end,
    "nvim config",
  },
  z = {
    function()
      require("willothy.util.fs").browse(vim.fn.stdpath("config") .. "/../zsh")
    end,
    "zsh config",
  },
}, modes.non_editing, "<leader>p")
