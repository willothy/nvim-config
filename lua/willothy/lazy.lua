local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=main",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- devicons
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      override_by_filename = {
        terminal = {
          icon = "",
          color = "#7ec699",
          name = "ToggleTerm",
        },
      },
      override_by_extension = {
        tl = {
          icon = "",
          color = "#72d6d6",
          name = "Teal",
        },
      },
    },
  },

  { import = "plugins" },
  {
    "dstein64/vim-startuptime",
    lazy = true,
    cmd = "StartupTime",
  },

  -- Neoclip
  {
    "kkharji/sqlite.lua",
    module = "sqlite",
    lazy = true,
  },
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = { "kkharji/sqlite.lua", module = "sqlite" },
    config = true,
    lazy = true,
  },

  -- bufdelete (used to open dash when all buffers are closed)
  "famiu/bufdelete.nvim",

  -- surround
  "tpope/vim-surround",
}, {
  ui = {
    -- a number <1 is a percentage., >1 is a fixed size
    size = { width = 0.8, height = 0.8 },
    wrap = false, -- wrap the lines in the ui
    -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
    border = "rounded",
  },
})
