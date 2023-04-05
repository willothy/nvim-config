if vim.g.minimal then
	return
end
local wk = require("which-key")
local util = require("willothy.util")

local function register(modes, mappings, opts)
	if type(modes) == "table" then
		for _, mode in ipairs(modes) do
			wk.register(mappings, vim.tbl_deep_extend("keep", { mode = mode }, opts or {}))
		end
	else
		wk.register(mappings, vim.tbl_deep_extend("keep", { mode = modes }, opts or {}))
	end
end

local function nop(key)
	vim.keymap.set({ "n" }, key, "<nop>", { noremap = true })
end
nop("[s")
nop("]s")

vim.api.nvim_set_keymap("", ",", " ", {
	noremap = true,
	desc = "Leader 2",
})

-- Spider
register({ "n", "o", "x" }, {
	name = "spider",
	w = {
		function()
			require("spider").motion("w")
		end,
		"Spider-w",
	},
	e = {
		function()
			require("spider").motion("e")
		end,
		"Spider-e",
	},
	b = {
		function()
			require("spider").motion("b")
		end,
		"Spider-b",
	},
	ge = {
		function()
			require("spider").motion("ge")
		end,
		"Spider-ge",
	},
})

register("i", {
	["<F1>"] = {
		"<nop>",
		"Pick buffer",
	},
})

register("n", {
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
	T = { "<Cmd>TroubleToggle document_diagnostics<CR>", "Toggle trouble" },
	["<Tab>"] = { "V>", "Indent line" },
	["<S-Tab>"] = { "V<", "Unindent line" },
	["<F1>"] = {
		function()
			require("cokeline.mappings").pick("focus")
		end,
		"Pick buffer",
	},
	["<C-s>"] = {
		function()
			vim.cmd("write")
		end,
		"Save",
	},
})
register({ "n", "t" }, {
	["<C-w>"] = {
		name = "window",
		["<Up>"] = { util.bind(vim.cmd, "wincmd k"), "Move to window up" },
		["<Down>"] = { util.bind(vim.cmd, "wincmd j"), "Move to window down" },
		["<Left>"] = { util.bind(vim.cmd, "wincmd h"), "Move to window left" },
		["<Right>"] = { util.bind(vim.cmd, "wincmd l"), "Move to window right" },
		["k"] = { util.bind(vim.cmd, "wincmd k"), "Move to window up" },
		["j"] = { util.bind(vim.cmd, "wincmd j"), "Move to window down" },
		["h"] = { util.bind(vim.cmd, "wincmd h"), "Move to window left" },
		["l"] = { util.bind(vim.cmd, "wincmd l"), "Move to window right" },
		x = {
			function()
				vim.api.nvim_exec("WinShift swap", true)
			end,
			"Swap windows",
		},
		["<C-w>"] = {
			function()
				vim.api.nvim_exec("WinShift", true)
			end,
			"Enter WinShift mode",
		},
	},
})

register("t", {
	["<Esc>"] = { "<C-\\><C-n>", "Exit terminal" },
})

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
	b = {
		p = {
			function()
				require("cokeline.mappings").pick("buffer")
			end,
			"Pick buffer",
		},
		cp = {
			function()
				require("cokeline.mappings").by_step("close", -1)
			end,
			"Close previous",
		},
		cn = {
			function()
				require("cokeline.mappings").by_step("close", 1)
			end,
			"Close next",
		},
	},
	s = {
		function()
			require("cokeline.mappings").pick("focus")
		end,
		"Focus buffer",
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
				require("telescope.builtin").buffers()
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
		h = { util.bind(util.browse, vim.loop.os_homedir()), "Browse home directory" },
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
		b = {
			function()
				require("blam").peek()
			end,
			"Peek line blame",
		},
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
	D = { ":Veil<CR>", "Return to dashboard" },
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
