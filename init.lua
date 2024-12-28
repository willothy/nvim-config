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

require("lazy").setup({
  {
    "configuration",
    virtual = true,
    config = function()
      require("willothy")
    end,
  },
  {
    "settings",
    virtual = true,
    lazy = false,
    config = function()
      require("willothy.settings")
    end,
    dependencies = { "configuration" },
  },
  {
    "autocmds",
    event = "VeryLazy",
    virtual = true,
    config = function()
      require("willothy.autocmds")
    end,
  },
  {
    "keymap",
    event = "VeryLazy",
    virtual = true,
    config = function()
      require("willothy.keymap")
    end,
  },
  {
    "commands",
    event = "VeryLazy",
    main = "willothy.commands",
    virtual = true,
    config = function()
      require("willothy.commands")
    end,
  },
  {
    "macros",
    main = "willothy.macros",
    event = "VeryLazy",
    virtual = true,
    config = true,
  },
  {
    "ui",
    virtual = true,
    event = "UiEnter",
    config = function()
      require("willothy.ui.scrollbar").setup()
      require("willothy.ui.scrolleof").setup()
      require("willothy.ui.code_actions").setup()
      require("willothy.ui.mode").setup()
    end,
  },

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
  "loganswartz/polychrome.nvim",
  "folke/tokyonight.nvim",
  "rebelot/kanagawa.nvim",
  "eldritch-theme/eldritch.nvim",
  "diegoulloao/neofusion.nvim",
  "comfysage/evergarden",
  "ray-x/aurora",
  "vague2k/vague.nvim",
  {
    "0xstepit/flow.nvim",
    config = true,
  },
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
