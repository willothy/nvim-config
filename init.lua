vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = ","

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" },
  {
    name = "willothy.init",
    dir = ".",
    lazy = false,
    config = function()
      -- things that need to be setup right away
      require("willothy")
    end,
  },
  {
    name = "willothy.lazy",
    dir = ".",
    event = "VeryLazy",
    config = function()
      -- lazy initialization
      require("willothy.lazy")
    end,
  },
}, {
  defaults = {
    lazy = true,
    event = "VeryLazy",
  },
  browser = "brave",
  diff = {
    cmd = "diffview.nvim",
  },
  performance = {
    cache = { enabled = true },
    reset_packpath = true,
    rtp = {
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
