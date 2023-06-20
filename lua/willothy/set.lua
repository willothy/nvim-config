local o = vim.o
local O = vim.opt
local icons = require("willothy.icons")
local _util = require("willothy.util")
local Iter = require("litter")

vim.api.nvim_exec('let &t_Cs = "\\e[4:0m"', true)
vim.api.nvim_exec('let &t_Ce = "\\e[4:0m"', true)

vim.cmd.colorscheme("minimus")

vim.o.shell = "bash"

o.swapfile = true
o.backup = false
--O.undodir = os.getenv("HOME") .. "/.vim/undodir"
o.undofile = true

o.hlsearch = false
o.incsearch = true
o.lazyredraw = true
o.cursorline = false
o.ttyfast = true

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

O.splitkeep = "screen"

O.listchars = { tab = "  ", extends = "", precedes = "" }

o.number = true
o.relativenumber = true

o.numberwidth = 1
o.wrap = false
o.expandtab = true

O.numberwidth._info.default = 1

vim.api.nvim_create_autocmd({
	"ModeChanged",
	"BufEnter",
	"TermResponse",
}, {
	callback = function()
		vim.cmd("checktime")
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
		expandtab = true,
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
	c = {
		buffer = {
			tabstop = 2,
			shiftwidth = 2,
		},
	},
	make = {
		buffer = {
			expandtab = false,
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

vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function(ev)
		local buf = ev.buf
		local ft = vim.bo[buf].filetype
		local bt = vim.bo[buf].buftype
		if bt == "" then
			local options = filetypes[ft] or default
			for k, v in pairs(options) do
				if k == "global" then
					for ik, iv in pairs(v) do
						vim.api.nvim_set_option(ik, iv)
					end
				elseif k == "window" then
					for ik, iv in pairs(v) do
						vim.api.nvim_win_set_option(0, ik, iv)
					end
				elseif k == "buffer" then
					for ik, iv in pairs(v) do
						vim.api.nvim_buf_set_option(buf, ik, iv)
					end
				end
			end
			local ok, _ = pcall(vim.cmd, "Gcd")
			if ok == false then
				vim.cmd("lcd %:p:h")
			end
		elseif bt == "terminal" then
			for k, v in pairs(terminal) do
				if k == "global" then
					for ik, iv in pairs(v) do
						vim.api.nvim_set_option(ik, iv)
					end
				elseif k == "window" then
					for ik, iv in pairs(v) do
						vim.api.nvim_win_set_option(0, ik, iv)
					end
				elseif k == "buffer" then
					for ik, iv in pairs(v) do
						vim.api.nvim_buf_set_option(buf, ik, iv)
					end
				end
			end
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "h", "cpp", "hpp" },
	group = vim.api.nvim_create_augroup("ft_set_treesitter", { clear = true }),
	callback = function()
		vim.treesitter.start()
	end,
})
