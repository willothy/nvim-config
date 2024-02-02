-- This may be done automatically in the future (see https://github.com/neovim/neovim/pull/24044)
vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = "," -- TODO: I don't use this much. I should.

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

package.preload["sidecar"] = function()
  local path = conf_path .. "/lua/sidecar.so"
  local lib = package.loadlib(path, "luaopen_sidecar")
  if not lib then
    vim.notify("sidecar.so not found.", vim.log.levels.WARN)
    return
    -- this could get annoying. I'd rather have an error I think.
    -- once this module is more developed I will move it into a "plugin"
    -- so lazy can manage it.
    -- vim
    --   .system({ "cargo", "build", "--release" }, {
    --     cwd = conf_path,
    --     timeout = 60000,
    --   })
    --   :wait()
    -- vim.uv.fs_rename(conf_path .. "/target/release/libsidecar.so", path)
    -- lib = package.loadlib(path, "luaopen_sidecar")
  end
  return lib()
end

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
    priority = 10000,
    config = true,
    event = "VimEnter",
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
        "spellfile",
      },
    },
  },
})
