vim.g.mapleader = " "
vim.g.maplocalleader = "," -- TODO: I don't use this much. I should.

local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

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

require("willothy")
require("willothy.settings")

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require("willothy.autocmds")
    require("willothy.keymap")
    require("willothy.commands")
    require("willothy.state")

    require("willothy.line-numbers")

    require("configs.macros").setup()
  end,
})

require("lazy").setup({
  { import = "plugins.editor" },
  { import = "plugins.ui" },
  { import = "plugins.libraries" },
  { import = "plugins.lsp" },
  { import = "plugins.util" },
  {
    "willothy/minimus",
    priority = 100,
    config = function()
      vim.cmd.colorscheme("minimus")
    end,
    event = "UiEnter",
  },
  -- {
  --   "willothy/libsql-lua",
  --   -- dir = "~/projects/rust/libsql-lua/",
  --   lazy = false,
  --   build = "build.lua",
  -- },
  "loganswartz/polychrome.nvim",
  "folke/tokyonight.nvim",
  "rebelot/kanagawa.nvim",
  "eldritch-theme/eldritch.nvim",
  "diegoulloao/neofusion.nvim",
  "comfysage/evergarden",
  "ray-x/aurora",
  "vague2k/vague.nvim",
}, {
  defaults = {
    lazy = true,
    cond = not vim.g.started_by_firenvim,
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
  dev = {
    -- fallback = true,
    -- path = "~/projects/lua/",
  },
  -- profiling = {
  --   loader = true,
  --   require = true,
  -- },
  pkg = {
    enabled = true,
    -- dir = conf_path,
    sources = {
      "lazy",
      "rockspec",
      "packspec",
    },
  },
  -- rocks = {
  --   -- server = "https://nvim-neorocks.github.io/rocks-binaries",
  -- },
  performance = {
    cache = {
      enabled = true,
      -- disable_events = { "UiEnter" },
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
        "spellfile",
      },
    },
  },
})
