local keymap = willothy.map
local modes = keymap.modes

local wk = require("which-key")

wk.register({
  name = "projects",
  f = {
    function()
      willothy.fs.browse("~/projects/")
    end,
    "projects",
  },
  F = {
    function()
      local buf = vim.api.nvim_get_current_buf()
      local dir
      if vim.bo[buf].buftype == "" then
        dir = vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
      else
        dir = vim.fn.getcwd()
      end
      willothy.fs.browse(dir)
    end,
    "current file parent dir",
  },
  v = {
    function()
      willothy.fs.browse(vim.fn.getcwd(-1))
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
}, { mode = modes.non_editing, prefix = "<leader>p" })
