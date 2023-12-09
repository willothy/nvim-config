local M = {}

function M.setup()
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
  vim.opt.cursorlineopt = "number"

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
  -- o.foldopen = "block,hor,mark,percent,quickfix,search,tag,undo"
  -- o.foldopen = "block,mark,percent,quickfix,search,tag,undo"
  -- vim.opt.foldmethod = "expr"
  -- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  -- vim.opt.foldtext = "v:lua.willothy.ui.foldtext()"

  o.splitkeep = "topline"
  -- o.splitkeep = "cursor"

  -- Pcall to avoid errors on older versions of nvim
  pcall(function()
    o.smoothscroll = true
  end)

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
end

return M
