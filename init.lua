vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.loader.enable()

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins.cmp" },
  { import = "plugins.dap" },
  { import = "plugins.editor" },
  { import = "plugins.git" },
  { import = "plugins.lsp" },
  { import = "plugins.navigation" },
  { import = "plugins.status" },
  { import = "plugins.ui" },
  { import = "plugins.terminal" },
  { import = "plugins.util" },
  { import = "plugins.windows" },
}, {
  defaults = {
    lazy = true,
    event = "VeryLazy",
  },
  ui = {
    size = { width = 0.8, height = 0.8 },
    wrap = false,
    border = "rounded",
  },
  install = {
    missing = true,
    colorscheme = { "minimus" },
  },
  browser = "brave",
  diff = {
    cmd = "diffview.nvim",
  },
  change_detection = {
    notify = false,
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
      },
    },
  },
})

if vim.g.started_by_firenvim then vim.g.minimal = true end
if vim.g.minimal then return end

require("willothy")
