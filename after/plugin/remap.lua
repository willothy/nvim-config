if vim.g.minimal then
	return
end
local wk = require("which-key")
local util = require("willothy.util")

-- unbind f1 help bc it's ANNOYING
vim.api.nvim_set_keymap("n", "<F1>", "<NOP>", { silent = true })

wk.register({
	["<C-e>"] = {
		function()
			require("harpoon.ui").toggle_quick_menu()
		end,
		"Toggle harpoon quick menu",
	},
	["<M-k>"] = {
		function()
			require("moveline").up()
		end,
		"Move line up",
	},
	["<M-j>"] = {
		function()
			require("moveline").down()
		end,
		"Move line down",
	},
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
	T = { "<Cmd>TroubleToggle document_diagnostics<CR>", "Toggle trouble" },
	["<Tab>"] = { "V>", "Indent line" },
	["<S-Tab>"] = { "V<", "Unindent line" },
}, {})

wk.register({
	a = {
		function()
			require("harpoon.mark").add_file()
		end,
		"Add file to harpoon",
	},
	t = {
		name = "terminal",
		t = {
			function()
				require("nvterm.terminal").toggle("horizontal")
			end,
			"Toggle terminal",
		},
		s = {
			function()
				local term = require("nvterm.terminal")
				vim.ui.input({
					prompt = "$ ",
				}, function(input)
					term.send(input, "horizontal")
				end)
			end,
			"Send to terminal",
		},
		p = {
			function()
				require("willothy.terminals").py:toggle()
			end,
			"Python repl",
		},
		l = {
			function()
				require("willothy.terminals").lua:toggle()
			end,
			"Lua repl",
		},
		c = {
			name = "cargo",
			r = {
				function()
					require("willothy.terminals").cargo_run:toggle()
				end,
				"Cargo run",
			},
			t = {
				function()
					require("willothy.terminals").cargo_test:toggle()
				end,
				"Cargo test",
			},
		},
	},
	s = {
		function()
			require("cokeline.mappings").pick("focus")
		end,
		"Focus buffer",
	},
	b = {
		function()
			require("blam").peek()
		end,
		"Peek line blame",
	},
	u = { vim.cmd.UndotreeToggle, "Toggle undotree" },
	f = {
		name = "file",
		f = {
			function()
				require("telescope").extensions.menufacture.find_files()
			end,
			"Find files",
		},
		g = {
			function()
				require("telescope").extensions.menufacture.git_files()
			end,
			"Find git files",
		},
		s = {
			function()
				require("telescope").extensions.menufacture.grep_string()
			end,
			"Grep string",
		},
		b = {
			function()
				require("telescope").builtin.buffers()
			end,
			"Find buffers",
		},
		n = { "<cmd>enew<CR>", "Create a new buffer" },
		v = {
			function()
				util.browse(vim.fn.expand("%:p:h"))
			end,
			"Browse current file's directory",
		},
		p = {
			function()
				vim.ui.input({ prompt = "Path: " }, function(input)
					util.browse(input)
				end)
			end,
			"Browse path from input",
		},
	},
	p = {
		name = "project",
		f = { util.bind(util.browse, "~/projects/"), "Browse projects" },
		v = { util.bind(util.browse), "Browse current directory" },
		r = { util.bind(util.browse, util.project_root), "Browse project root" },
		cr = { util.bind(util.browse, util.crate_root), "Browse crate root" },
		pc = { util.bind(util.browse, util.parent_crate), "Browse parent crate" },
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
		["$"] = "Block comment to end of line",
	},
	n = {
		name = "neovim",
		v = { util.bind(util.browse, vim.fn.stdpath("config")), "Browse nvim config" },
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

						util.reload(input)
					end)
				end,
				"Reload plugin",
			},
		},
	},
	w = { util.bind(vim.api.nvim_exec, "w", true), "Save" },
	D = { ":Alpha<CR>", "Return to dashboard" },
}, { prefix = "<leader>" })

wk.register({
	["<M-k>"] = {
		function()
			require("moveline").block_up()
		end,
		"Move block up",
	},
	["<M-j>"] = {
		function()
			require("moveline").block_down()
		end,
		"Move block down",
	},
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
