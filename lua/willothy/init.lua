vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.loader.enable()

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  defaults = {
    lazy = true,
    event = "VeryLazy",
  },
  spec = vim.g.minimal and "willothy.minimal" or "plugins",
  -- dev = { path = "~/projects/lua/" },
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

if vim.g.minimal then return end

require("willothy.set")

local function initialize()
  -- setup mappings
  require("willothy.mappings")

  -- setup hydras
  require("willothy.hydras")

  vim.defer_fn(function()
    vim.api.nvim_exec_autocmds("User", { pattern = "ExtraLazy" })
  end, 100)
  -- Inform vim how to enable undercurl in wezterm
  vim.api.nvim_exec2(
    [[
let &t_Cs = "\e[4:3m"
let &t_Ce = "\e[4:0m"
    ]],
    { output = false }
  )
end

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = vim.schedule_wrap(function()
    -- require("lazy").load("willothy")

    initialize()
  end),
})

vim.api.nvim_create_autocmd("User", {
  pattern = "ExtraLazy",
  once = true,
  callback = function()
    -- setup commands
    require("willothy.commands")

    -- setup annoying "use hjkl" messages
    -- require("willothy.hjkl")()
  end,
})

-- setup float dragging
-- require("willothy.ui").setup({
--   resize = "<S-LeftDrag>",
-- })

-- Hacky way of detaching UI
-- vim.api.nvim_create_user_command("Detach", function()
--   local uis = vim.api.nvim_list_uis()
--   if #uis < 1 then return end
--   local chan = uis[1].chan
--   vim.fn.chanclose(chan)
-- end, {})
