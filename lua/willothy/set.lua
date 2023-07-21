local o = vim.o
local opt = vim.opt
local icons = require("willothy.icons")

vim.api.nvim_exec('let &t_Cs = "\\e[4:0m"', true)
vim.api.nvim_exec('let &t_Ce = "\\e[4:0m"', true)

vim.cmd.colorscheme("minimus")

vim.o.shell = "bash"

vim.o.shortmess = "filnxoOCFIs"

vim.o.virtualedit = "block"

o.swapfile = true
o.backup = false
o.undofile = true

o.hlsearch = false
o.incsearch = true
o.cursorline = false

o.termguicolors = true

o.scrolloff = 16

o.updatetime = 150
o.mousemodel = "extend"
o.mousemoveevent = true

o.conceallevel = 2

o.foldcolumn = "1"
o.foldlevel = 99
o.foldenable = true
o.foldlevelstart = 99

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

opt.splitkeep = "screen"

opt.sessionoptions = {
  "buffers",
  "tabpages",
  "globals",
}

o.laststatus = 3

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

vim.api.nvim_create_autocmd({
  "TermResponse",
}, {
  callback = function() vim.cmd("checktime") end,
})

local groupname = "return_to_mark"
vim.api.nvim_create_augroup(groupname, { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  group = groupname,
  pattern = "*",
  callback = function()
    local line = vim.fn.line([['"]])
    if line > 0 and line <= vim.api.nvim_buf_line_count(0) then
      vim.cmd.normal({ [[g`"zz]], bang = true })
    end
  end,
  once = false,
})
