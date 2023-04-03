local o = vim.o
local O = vim.opt
local g = vim.g
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
--o.fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldclose:"
o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
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

------------------------ Test ------------------------------
-- o.wrap = false
-- o.list = true
-- O.listchars = { tab = "  ", extends = "", precedes = "" }
-- o.title = true
-- o.clipboard = "unnamedplus"
-- o.cmdheight = 0
-- o.smartindent = true
-- o.tabstop = 2
-- o.shiftwidth = 2
-- O.shortmess:append("sI")
-- o.smartcase = true
-- o.ignorecase = true
-- o.number = true
-- o.relativenumber = true
-- o.splitbelow = true
-- o.splitright = true
-- vim.F.npcall(function()
-- 	o.splitkeep = "screen"
-- end)
-- o.numberwidth = 1
-- o.termguicolors = true
-- o.timeoutlen = 400
-- o.undofile = true
-- o.updatetime = 250
-- o.spell = true
-- o.spelloptions = "camel"
-- o.shell = "/bin/sh"
-- o.signcolumn = "auto:2"
-- o.completeopt = "menu,menuone,noselect"
-- o.showmode = false
-- o.confirm = true
-- o.laststatus = 3
-- o.pumheight = math.floor(o.lines / 2)
-- o.foldcolumn = "1"
-- o.mousemodel = "extend"
-- -- o.virtualedit = "all"
-- o.cursorline = true
-- o.cursorlineopt = "number"
-- o.fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldclose:"
-- --o.statuscolumn = "%@ScFa@%C%T%@ScSa@%s%T%@ScLa@%=%{&nu?((v:relnum?v:relnum:v:lnum).'│'):''}%T"
--
-- g.mapleader = " "
-- g.maplocalleader = ","
-- g.loaded_2html_plugin = 1
-- g.loaded_fzf = 1
-- g.loaded_getscript = 1
-- g.loaded_getscriptPlugin = 1
-- g.loaded_gzip = 1
-- g.loaded_logiPat = 1
-- g.loaded_netrw = 1
-- g.loaded_netrwPlugin = 1
-- g.loaded_netrwSettings = 1
-- g.loaded_netrwFileHandlers = 1
-- g.loaded_tar = 1
-- g.loaded_tarPlugin = 1
-- g.loaded_rrhelper = 1
-- g.loaded_spellfile_plugin = 1
-- g.loaded_vimball = 1
-- g.loaded_vimballPlugin = 1
-- g.loaded_zip = 1
-- g.loaded_zipPlugin = 1
-- g.loaded_matchit = 1
-- g.loaded_matchparen = 1
-- g.loaded_node_provider = 0
-- g.loaded_perl_provider = 0
-- g.loaded_python_provider = 0
-- g.loaded_python3_provider = 0
-- g.loaded_ruby_provider = 0
