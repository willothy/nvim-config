local wk = require("which-key")
local telescope = require("telescope")
local builtin = require("telescope.builtin")
local menufacture = telescope.extensions.menufacture
local moveline = require("moveline")
local mark = require("harpoon.mark")
local hui = require("harpoon.ui")
local terms = require("willothy.terminals")

wk.register({
	["<C-e>"] = { hui.toggle_quick_menu, "Toggle harpoon quick menu" },
	["<M-k>"] = { moveline.up, "Move line up" },
	["<M-j>"] = { moveline.down, "Move line down" },
	["<C-w>"] = {
		name = "window",
		x = {
			function()
				vim.api.nvim_exec("WinShift swap", true)
			end,
			"Swap windows",
		},
		w = {
			function()
				vim.api.nvim_exec("WinShift", true)
			end,
			"Enter WinShift mode",
		},
	},
	-- z = {
	-- 	name = 'folds',
	-- 	p = { require('fold-preview').toggle_preview, "Toggle fold preview" }
	-- },
	T = { "<Cmd>TroubleToggle document_diagnostics<CR>", "Toggle trouble" },
	["<Tab>"] = { "V>", "Indent line" },
	["<S-Tab>"] = { "V<", "Unindent line" },
}, {})

wk.register({
	a = { mark.add_file, "Add file to harpoon" },
	t = {
		name = "terminal",
		t = {
			function()
				require("toggleterm").toggle(vim.v.count)
			end,
			"Toggle terminal",
		},
		p = {
			function()
				terms.py:toggle()
			end,
			"Python repl",
		},
		l = {
			function()
				terms.lua:toggle()
			end,
			"Lua repl",
		},
		c = {
			name = "cargo",
			r = {
				function()
					terms.cargo_run:toggle()
				end,
				"Cargo run",
			},
			t = {
				function()
					terms.cargo_test:toggle()
				end,
				"Cargo test",
			},
		},
	},
	b = { require("blam").peek, "Peek line blame" },
	u = { vim.cmd.UndotreeToggle, "Toggle undotree" },
	f = {
		name = "file",
		f = { menufacture.find_files, "Find files" },
		g = { menufacture.git_files, "Find git files" },
		s = { menufacture.grep_string, "Grep string" },
		b = { builtin.buffers, "Find buffers" },
		n = { "<cmd>enew<CR>", "Create a new buffer" },
		v = { "<cmd>cd %:p:h<CR>", "Browse current file's directory" },
		p = {
			function()
				vim.ui.input({ prompt = "Path: " }, function(input)
					Browse(input)
				end)
			end,
			"Browse path from input",
		},
	},
	p = {
		name = "project",
		f = { Wrap(Browse, "~/projects/"), "Browse projects" },
		v = { Wrap(Browse), "Browse current directory" },
		r = { Wrap(BrowseCrateRoot), "Browse crate root" },
		p = { Wrap(ParentCrate), "Browse parent crate" },
	},
	c = {
		name = "comment",
		c = "Comment current line",
		b = "Block comment current line",
	},
	g = {
		name = "git",
		s = { vim.cmd.Git, "Open fugitive" },
	},
	l = {
		name = "comment",
		["$"] = "Block comment to end of line",
	},
	n = {
		name = "neovim",
		v = { Wrap(Browse, Wrap(vim.fn.stdpath, "config")), "Browse nvim config" },
		s = { ":so %", "Source current file" },
		u = {
			name = "utils",
			r = {
				function()
					vim.ui.input({
						prompt = "plugin: ",
					}, function(input)
						if not input then
							return
						end

						require("willothy.util").reload(input)
					end)
				end,
				"Reload plugin",
			},
		},
	},
	w = { Wrap(vim.api.nvim_exec, "w", true), "Save" },
	D = { ":Alpha<CR>", "Return to dashboard" },
}, { prefix = "<leader>" })

wk.register({
	["<M-k>"] = { moveline.block_up, "Move block up" },
	["<M-j>"] = { moveline.block_down, "Move block down" },
	["<Tab>"] = { ">gv", "Indent line" },
	["<S-Tab>"] = { "<gv", "Unindent line" },
}, {
	mode = "v",
})

wk.register({
	["<Esc>"] = { "<C-\\><C-n>", "Exit terminal" },
	["<C-w>"] = {
		name = "window",
		["<Up>"] = { "<C-\\><C-n><C-w>k", "Move to window up" },
		["<Down>"] = { "<C-\\><C-n><C-w>j", "Move to window down" },
		["<Left>"] = { "<C-\\><C-n><C-w>h", "Move to window left" },
		["<Right>"] = { "<C-\\><C-n><C-w>l", "Move to window right" },
		["k"] = { "<C-\\><C-n><C-w>k", "Move to window up" },
		["j"] = { "<C-\\><C-n><C-w>j", "Move to window down" },
		["h"] = { "<C-\\><C-n><C-w>h", "Move to window left" },
		["l"] = { "<C-\\><C-n><C-w>l", "Move to window right" },
	},
}, { mode = "t" })
