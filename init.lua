-- This may be done automatically in the future (see https://github.com/neovim/neovim/pull/24044)
vim.loader.enable()

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

-- package.preload["sidecar"] = function()
--   local path = conf_path .. "/lua/sidecar.so"
--   local lib = package.loadlib(path, "luaopen_sidecar")
--   if not lib then
--     vim.notify("sidecar.so not found.", vim.log.levels.WARN)
--     return
--     -- this could get annoying. I'd rather have an error I think.
--     -- once this module is more developed I will move it into a "plugin"
--     -- so lazy can manage it.
--     -- vim
--     --   .system({ "cargo", "build", "--release" }, {
--     --     cwd = conf_path,
--     --     timeout = 60000,
--     --   })
--     --   :wait()
--     -- vim.uv.fs_rename(conf_path .. "/target/release/libsidecar.so", path)
--     -- lib = package.loadlib(path, "luaopen_sidecar")
--   end
--   return lib()
-- end

require("willothy")
require("willothy.settings")

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require("willothy.autocmds")
    require("willothy.keymap")
    require("willothy.commands")
  end,
})

require("lazy").setup({
  { import = "plugins" },
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
    path = "~/projects/lua/",
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
    },
  },
  rocks = {
    -- server = "https://nvim-neorocks.github.io/rocks-binaries",
  },
  performance = {
    cache = {
      enabled = true,
      disable_events = { "UiEnter" },
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
