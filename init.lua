vim.loader.enable()

if vim.g.neovide then
  vim.o.guifont = "FiraCode Nerd Font:h10"
  vim.o.guifont = "FiraCode Nerd Font:h10"
end

vim.g.mapleader = " "
vim.g.maplocalleader = ","

local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

local conf_path = vim.fn.stdpath("config")
---@cast conf_path string

vim.opt.rtp:prepend(lazy_path)

require("lazy").setup({
  { import = "plugins" },
  {
    name = "willothy",
    main = "willothy",
    dir = conf_path,
    lazy = false,
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
    colorscheme = { "minimus" },
  },
  browser = "brave",
  diff = {
    cmd = "diffview.nvim",
  },
  ui = {
    border = {
      { " ", "NormalFloat" },
      { " ", "NormalFloat" },
      { " ", "NormalFloat" },
      { " ", "NormalFloat" },
      { " ", "NormalFloat" },
      { " ", "NormalFloat" },
      { " ", "NormalFloat" },
      { " ", "NormalFloat" },
    },
  },
  performance = {
    cache = {
      enabled = true,
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
