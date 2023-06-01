local o = vim.o
local O = vim.opt
local icons = require("willothy.icons")
local _util = require("willothy.util")
local Iter = require("litter")

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
o.mousemoveevent = true

--o.virtualedit = "all"

-- o.signcolumn = "auto:2"

o.foldcolumn = "1"
o.fillchars = [[eob: ,fold: ,foldopen:]] .. icons.fold.open .. [[,foldsep: ,foldclose:]] .. icons.fold.closed
o.foldlevel = 99
o.foldenable = true
o.foldlevelstart = 99

o.laststatus = 3

O.listchars = { tab = "  ", extends = "", precedes = "" }

o.number = true
o.relativenumber = true

O.numberwidth._info.default = 1

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
	global = {
		numberwidth = 1,
	},
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
	text = {
		window = {
			wrap = true,
		},
	},
}

local terminal = vim.tbl_deep_extend("keep", {
	window = {
		number = false,
		relativenumber = false,
		numberwidth = 1,
	},
	buffer = {
		tabstop = 4,
	},
}, default)

for ft, options in pairs(filetypes) do
	filetypes[ft] = vim.tbl_deep_extend("keep", options, default)
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter", "TermOpen" }, {
	pattern = "*",
	callback = function(ev)
		local buf = ev.buf
		local ft = vim.bo[buf].filetype
		local bt = vim.bo[buf].buftype
		if bt == "" then
			local options = filetypes[ft] or default
			Iter:from_map(options.buffer)
				:each(function(v)
					vim.api.nvim_buf_set_option(buf, v[1], v[2])
				end)
				:chain(Iter:from_map(options.window):each(function(v)
					vim.api.nvim_win_set_option(0, v[1], v[2])
				end))
				:chain(Iter:from_map(options.global):each(function(v)
					vim.api.nvim_set_option(v[1], v[2])
				end))
				:collect()
			local ok, _ = pcall(vim.cmd, "Gcd")
			if ok == false then
				vim.cmd("lcd %:p:h")
			end
		elseif bt == "terminal" then
			Iter:from_map(terminal.window)
				:each(function(v)
					vim.api.nvim_win_set_option(0, v[1], v[2])
				end)
				:chain(Iter:from_map(terminal.buffer):each(function(v)
					vim.api.nvim_buf_set_option(buf, v[1], v[2])
				end))
				:chain(Iter:from_map(terminal.global):each(function(v)
					vim.api.nvim_set_option(v[1], v[2])
				end))
				:collect()
		end
	end,
})
