local o = vim.o
local O = vim.opt
local icons = require("willothy.icons")
local util = require("willothy.util")

vim.api.nvim_exec('let &t_Cs = "\\e[4:0m"', true)
vim.api.nvim_exec('let &t_Ce = "\\e[4:0m"', true)

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

local default = {
	global = {},
	window = {
		wrap = false,
		numberwidth = 1,
		number = true,
		relativenumber = true,
	},
	buffer = {
		tabstop = 4,
		softtabstop = -1,
		shiftwidth = 0,
		expandtab = false,
		smartindent = false,
	},
}

local filetypes = {
	markdown = {
		window = {
			wrap = true,
		},
	},
	lua = {
		buffer = {
			tabstop = 2,
			shiftwidth = 2,
		},
	},
}

for ft, options in pairs(filetypes) do
	filetypes[ft] = vim.tbl_deep_extend("keep", options, default)
end

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*",
	callback = function(ev)
		local buf = ev.buf
		local ft = vim.bo[buf].filetype
		local bt = vim.bo[buf].buftype
		local options = filetypes[ft] or default
		for opt, val in pairs(options.buffer) do
			vim.api.nvim_buf_set_option(buf, opt, val)
		end
		for opt, val in pairs(options.window) do
			vim.api.nvim_win_set_option(0, opt, val)
		end
		for opt, val in pairs(options.global) do
			vim.api.nvim_set_option(opt, val)
		end
		if bt == "" then
			-- local root = util.find_root({ "Cargo.toml", "init.lua", ".git/" })
			-- if root then
			-- 	vim.api.nvim_set_current_dir
			-- end
			local ok, _ = pcall(vim.cmd, "Gcd")
			if ok == false then
				vim.cmd("lcd %:p:h")
			end
		end
	end,
})
