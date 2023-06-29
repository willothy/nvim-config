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
  { import = "willothy.dev" },
  -- devicons
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      override = {},
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
    event = "VeryLazy",
  },
  --
  -- -- Crates
  -- {
  -- 	"saecki/crates.nvim",
  -- 	tag = "v0.3.0",
  -- 	lazy = true,
  -- 	enabled = false,
  -- },

  -- Transparency

  -- Status line
  -- {
  -- 	"willothy/lualine.nvim",
  -- 	branch = "active",
  -- 	dependencies = {
  -- 		"nvim-tree/nvim-web-devicons",
  -- 	},
  -- 	event = "VeryLazy",
  -- 	lazy = true,
  -- 	enabled = false,
  -- },

  -- Neoclip
  {
    "kkharji/sqlite.lua",
    module = "sqlite",
    lazy = true,
    event = "VeryLazy",
  },
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = { "kkharji/sqlite.lua", module = "sqlite" },
    config = function() require("neoclip").setup() end,
    lazy = true,
    event = "VeryLazy",
  },

  -- Telescope
  -- "nvim-lua/popup.nvim",

  -- tmux-navigator
  -- {
  -- 	"christoomey/vim-tmux-navigator",
  -- 	config = function() end,
  -- },

  -- bufdelete (used to open dash when all buffers are closed)
  "famiu/bufdelete.nvim",

  -- surround
  "tpope/vim-surround",

  -- Util for commands requiring password for sudo, ssh etc.
  -- "lambdalisue/askpass.vim",
}, {
  -- Options
  -- colorscheme = { "minimus" },
  ui = {
    -- a number <1 is a percentage., >1 is a fixed size
    size = { width = 0.8, height = 0.8 },
    wrap = false, -- wrap the lines in the ui
    -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
    border = "rounded",
  },
  -- defaults = {
  -- 	cond = os.getenv("NVIM") == nil,
  -- },
})
