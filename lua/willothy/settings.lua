local o = vim.o
local icons = willothy.icons

o.cmdheight = 0
o.scrolloff = 16
o.clipboard = "unnamedplus"

o.shell = "zsh"
o.shortmess = "filnxoOCFIs"
o.virtualedit = "block"
o.showtabline = 2
o.signcolumn = "yes"

o.swapfile = true
o.backup = false
o.undofile = true

o.hlsearch = false
o.incsearch = true
o.cursorline = false

o.termguicolors = true
o.modeline = false

vim.o.timeout = true
vim.o.timeoutlen = 250

o.updatetime = 500
o.mousemodel = "extend"
o.mousetime = 200
o.mousemoveevent = true

o.conceallevel = 2

o.foldcolumn = "1"
o.foldlevel = 99
o.foldenable = true
o.foldlevelstart = 99

o.splitkeep = "cursor"
o.mousescroll = "ver:1,hor:6"

o.laststatus = 3

o.number = true
o.relativenumber = true

o.tabstop = vim.bo.filetype == "lua" and 2 or 4
o.shiftwidth = vim.bo.filetype == "lua" and 2 or 4
o.softtabstop = -1
o.expandtab = true

o.wrap = false
o.numberwidth = 1
o.number = true
o.relativenumber = true

vim.opt.fillchars = {
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
