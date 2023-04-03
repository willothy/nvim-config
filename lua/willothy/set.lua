local o = vim.o
local O = vim.opt
local icons = require("willothy.icons")

vim.api.nvim_exec('let &t_Cs = "\\e[4:0m"', true)
vim.api.nvim_exec('let &t_Ce = "\\e[4:0m"', true)

o.tabstop = 4
o.softtabstop = -1
o.shiftwidth = 0
o.expandtab = true

o.smartindent = false

o.wrap = false

o.swapfile = true
o.backup = false
--O.undodir = os.getenv("HOME") .. "/.vim/undodir"
o.undofile = true

o.hlsearch = false
o.incsearch = true

o.termguicolors = true

o.scrolloff = 16
--o.isfname:append("@-@")

o.updatetime = 150
o.mousemodel = "extend"

--o.virtualedit = "all"

o.signcolumn = "auto:2"

o.numberwidth = 1
o.number = true
o.relativenumber = true

o.foldcolumn = "1"
o.fillchars = [[eob: ,fold: ,foldopen:]] .. icons.fold.open .. [[,foldsep: ,foldclose:]] .. icons.fold.closed
o.foldlevel = 99
o.foldenable = true
o.foldlevelstart = 99

o.laststatus = 3

O.listchars = { tab = "  ", extends = "", precedes = "" }

vim.api.nvim_create_autocmd({
	"ModeChanged",
	"BufEnter",
	"TermResponse",
}, {
	callback = function()
		vim.cmd("checktime")
		vim.cmd("redraw")
	end,
})

function has(arr, val)
	for _, value in ipairs(arr) do
		if value == val then
			return true
		end
	end
	return false
end

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		if vim.bo.filetype == "lua" then
			vim.opt.tabstop = 2
		else
			vim.opt.tabstop = 4
		end

		if ({ "toggleterm", "dashboard", "alpha", has = has }):has(vim.bo.filetype) then
			return
		end

		local ok, _ = pcall(vim.cmd, "Gcd")
		if ok == false then
			vim.cmd("lcd %:p:h")
		end
	end,
})
