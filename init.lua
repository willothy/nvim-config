-- hi

vim.g.mapleader = " "
vim.g.maplocalleader = "," -- TODO: I don't use this much. I should.

local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

vim.opt.rtp:prepend(lazy_path)

-- -- Loading shada is SLOW, so we're going to load it manually,
-- -- after UI-enter so it doesn't block startup.
-- local shada = vim.o.shada
-- vim.o.shada = ""
-- vim.api.nvim_create_autocmd("User", {
--   pattern = "VeryLazy",
--   callback = function()
--     vim.o.shada = shada
--     pcall(vim.cmd.rshada, { bang = true })
--   end,
-- })

require("lazy").setup({
  {
    "settings",
    virtual = true,
    lazy = false,
    config = function()
      require("willothy.settings")
    end,
  },
  {
    "autocmds",
    lazy = false,
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
    event = "CmdlineEnter",
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

  -- {
  --   "ziglang/zig.vim",
  --   event = "BufRead *.zig",
  -- },

  { import = "plugins.editor" },
  { import = "plugins.ui" },
  { import = "plugins.libraries" },
  { import = "plugins.lsp" },
  { import = "plugins.util" },
  { import = "plugins.fun" },

  {
    "minimus",
    virtual = true,
    config = function()
      vim.cmd.colorscheme("minimus")
    end,
    event = "UiEnter",
  },
  {
    "colorschemes",
    virtual = true,
    -- don't need to load until we're calling :colorscheme
    event = "CmdlineEnter",
    dependencies = {
      "folke/tokyonight.nvim",
      "eldritch-theme/eldritch.nvim",
      "diegoulloao/neofusion.nvim",
      "comfysage/evergarden",
      "ray-x/aurora",
      "S-Spektrum-M/odyssey.nvim",
      "AlexvZyl/nordic.nvim",
      {
        "0xstepit/flow.nvim",
        config = true,
      },
      {
        "wtfox/jellybeans.nvim",
        config = true,
      },
    },
  },
  "echasnovski/mini.colors",
}, {
  defaults = {
    lazy = true,
    cond = not vim.g.started_by_firenvim,
  },
  install = {
    missing = true,
    colorscheme = { "minimus" },
  },
  diff = {
    cmd = "diffview.nvim",
  },
  ui = {
    border = "solid",
  },
  dev = {
    path = "~/projects/lua/",
  },
  git = {
    throttle = {
      enabled = true,
      rate = 10,
      duration = 150,
    },
  },
  pkg = {
    enabled = true,
    sources = {
      "lazy",
      "packspec",
      "rockspec",
    },
  },
  rocks = {
    enabled = true,
    hererocks = true,
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
        "spellfile",
      },
    },
  },
})

-- require("snacks").profiler.start({
--   on_stop = {
--     highlights = false,
--   },
-- })

require("willothy.lib.fs").hijack_netrw()
