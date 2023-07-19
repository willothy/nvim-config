local o = vim.o
local O = vim.opt
local icons = require("willothy.icons")

vim.api.nvim_exec('let &t_Cs = "\\e[4:0m"', true)
vim.api.nvim_exec('let &t_Ce = "\\e[4:0m"', true)

vim.cmd.colorscheme("minimus")

vim.o.shell = "bash"

vim.o.shortmess = "filnxoOCFI"

o.swapfile = true
o.backup = false
o.undofile = true

o.hlsearch = false
o.incsearch = true
o.lazyredraw = true
o.cursorline = false

o.termguicolors = true

o.scrolloff = 16

o.updatetime = 150
o.mousemodel = "extend"
o.mousemoveevent = true

o.conceallevel = 2

o.foldcolumn = "1"
o.fillchars = [[eob: ,fold: ,foldopen:]]
  .. icons.fold.open
  .. [[,foldsep: ,foldclose:]]
  .. icons.fold.closed
o.foldlevel = 99
o.foldenable = true
o.foldlevelstart = 99

o.laststatus = 3

O.splitkeep = "screen"

O.listchars = { tab = "  ", extends = "", precedes = "" }

o.number = true
o.relativenumber = true

o.expandtab = true
o.tabstop = vim.bo.filetype == "lua" and 2 or 4
o.shiftwidth = vim.bo.filetype == "lua" and 2 or 4
o.softtabstop = -1
o.expandtab = true

o.wrap = false
o.numberwidth = 1
o.number = true
o.relativenumber = true

O.numberwidth._info.default = 1

vim.api.nvim_create_autocmd({
  "TermResponse",
}, {
  callback = function() vim.cmd("checktime") end,
})
