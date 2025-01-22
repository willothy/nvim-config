local o = vim.o
local opt = vim.opt
local icons = willothy.ui.icons

o.cmdheight = 0
o.scrolloff = 16

o.shell = "fish"

o.number = true
o.relativenumber = true
-- o.signcolumn = "yes"
o.signcolumn = "number"
-- o.relativenumber = false
-- o.number = false

o.shortmess = "filnxoOCFIsw"
o.virtualedit = "block"

o.wrap = false
o.autoread = true
o.showtabline = 2
o.laststatus = 3

o.swapfile = true
o.backup = false
o.undofile = true

o.hlsearch = false
o.incsearch = true
o.cursorline = true
o.cursorlineopt = "number"

o.modeline = false

o.timeout = true
o.timeoutlen = 250

o.updatetime = 500
o.mousemodel = "extend"
o.mousetime = 200
o.mousemoveevent = true

o.conceallevel = 3
o.confirm = true

o.foldcolumn = "1"
o.foldlevel = 99
o.foldlevelstart = 99
o.foldenable = true
-- o.foldopen = "block,hor,mark,percent,quickfix,search,tag,undo"
o.foldopen = "block,mark,percent,quickfix,search,tag,undo"
o.foldmethod = "expr"

o.foldtext = ""

vim.api.nvim_create_autocmd("User", {
  once = true,
  pattern = "VeryLazy",
  callback = function()
    -- just to keep treesitter lazy-loaded
    o.foldexpr = "v:lua.willothy.ui.foldexpr()"
  end,
})

o.syntax = "off"

o.splitkeep = "topline"
-- o.splitkeep = "cursor"

-- Pcall to avoid errors on older versions of nvim
o.smoothscroll = true

o.mousescroll = "ver:1,hor:6"

o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.expandtab = true

-- o.indentkeys = o.indentkeys .. ",!0\t"

opt.fillchars = {
  horiz = "─",
  horizup = "┴",
  horizdown = "┬",
  vert = "│",
  vertleft = "┤",
  vertright = "├",
  verthoriz = "┼",
  fold = "⠀",
  eob = " ",
  diff = "┃",
  msgsep = " ",
  foldsep = " ",
  foldclose = icons.fold.closed,
  foldopen = icons.fold.open,
}

vim.o.clipboard = "unnamedplus"

-- Wezterm doesn't support OSC 52 yet :(
--
-- vim.g.clipboard = {
--   name = "OSC 52",
--   copy = {
--     ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
--     ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
--   },
--   paste = {
--     ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
--     ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
--   },
-- }
