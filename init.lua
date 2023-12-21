vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.g.colors_name = "minimus"

local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

local conf_path = vim.fn.stdpath("config") --[[@as string]]

vim.opt.rtp:prepend(lazy_path)

-- Loading shada is SLOW, so we're going to load it manually,
-- after UI-enter so it doesn't block startup.
local shada = vim.o.shada
vim.o.shada = ""
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    vim.o.shada = shada
    pcall(vim.cmd.rshada, { bang = true })
  end,
})

require("lazy").setup({
  { import = "plugins" },
  -- This is how I get Lazy to profile my config.
  {
    name = "willothy.init",
    main = "willothy",
    dir = conf_path,
    lazy = false,
    config = true,
  },
  {
    name = "willothy.commands",
    main = "willothy.commands",
    dir = conf_path,
    event = "VeryLazy",
    config = true,
  },
  {
    name = "willothy.autocmds",
    main = "willothy.autocmds",
    dir = conf_path,
    event = "VeryLazy",
    config = true,
  },
  {
    name = "willothy.keymap",
    main = "willothy.keymap",
    dir = conf_path,
    event = "VeryLazy",
    config = true,
  },
  {
    name = "willothy.settings",
    main = "willothy.settings",
    dir = conf_path,
    event = "VimEnter",
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
    border = "solid",
  },
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      reset = true,
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
        "osc52", -- Wezterm doesn't support osc52 yet
      },
    },
  },
})
