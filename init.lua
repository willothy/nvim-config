vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = ","

local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local conf_path = vim.fn.stdpath("config")

vim.opt.rtp:prepend(lazy_path)

require("lazy").setup({
  { import = "plugins" },
  {
    name = "willothy",
    main = "willothy",
    dir = conf_path,
    lazy = false,
    priority = 100000,
    config = true,
  },
  {
    name = "willothy.lazy",
    main = "willothy.lazy",
    dir = conf_path,
    event = "VeryLazy",
    config = true,
  },
}, {
  defaults = {
    lazy = true,
  },
  install = {
    missing = true,
    colorscheme = { "minimus", "tokyonight" },
  },
  browser = "brave",
  diff = {
    cmd = "diffview.nvim",
  },
  performance = {
    cache = {
      enabled = true,
      disable_events = { "User ExtraLazy" },
    },
    reset_packpath = true,
    rtp = {
      reset = true,
      paths = {},
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "man",
      },
    },
  },
})
