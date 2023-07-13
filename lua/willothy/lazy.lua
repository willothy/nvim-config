local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  defaults = {
    lazy = true,
  },
  spec = "plugins",
  dev = { path = "~/projects/lua/" },
  ui = {
    size = { width = 0.8, height = 0.8 },
    wrap = false,
    border = "rounded",
  },
  browser = "brave",
  diff = {
    cmd = "diffview.nvim",
  },
  performance = {
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
