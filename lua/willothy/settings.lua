local o = vim.o
local icons = willothy.icons

o.cmdheight = 0
o.scrolloff = 16

o.shell = "/usr/bin/zsh"
o.shortmess = "filnxoOCFIs"
o.virtualedit = "block"
o.signcolumn = "yes"
o.wrap = false
o.number = true
o.relativenumber = true
o.showtabline = 2
o.laststatus = 3

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
-- o.foldopen = "block,mark,search,percent,undo"

o.splitkeep = "cursor"
o.smoothscroll = true
o.mousescroll = "ver:1,hor:6"

o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.expandtab = true

-- o.indentkeys = o.indentkeys .. ",!0\t"

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
