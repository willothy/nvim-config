local keymap = willothy.keymap
-- selene: allow(unused_variable)
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

register({
  name = "projects",
  f = {
    function()
      willothy.fs.browse("~/projects/")
    end,
    "projects",
  },
  v = {
    function()
      willothy.fs.browse()
    end,
    "current directory",
  },
  r = {
    function()
      willothy.fs.browse(willothy.fs.project_root())
    end,
    "project root",
  },
  h = {
    function()
      willothy.fs.browse(vim.loop.os_homedir())
    end,
    "home directory",
  },
  n = {
    function()
      willothy.fs.browse(vim.fn.stdpath("config"))
    end,
    "nvim config",
  },
  z = {
    function()
      willothy.fs.browse(vim.fn.stdpath("config") .. "/../zsh")
    end,
    "zsh config",
  },
}, modes.non_editing, "<leader>p")
