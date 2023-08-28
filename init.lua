vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = ","

local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

local conf_path = vim.fn.stdpath("config")
---@cast conf_path string

vim.opt.rtp:prepend(lazy_path)

vim.api.nvim_create_user_command(
  "E",
  vim.schedule_wrap(function(o)
    vim.print(o.fargs)
    for i, file in vim.iter(o.fargs):enumerate() do
      local buf = vim.fn.bufadd(file)
      if buf then
        vim.fn.bufload(buf)
        vim.bo[buf].buflisted = true
        if i == 1 then
          vim.api.nvim_set_current_buf(buf)
        end
      end
    end
  end),
  { nargs = "*" }
)

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
