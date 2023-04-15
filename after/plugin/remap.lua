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

local function mkportal(title, items, callback, opts)
	opts = vim.tbl_deep_extend("keep", opts or {}, {
		max_results = 4,
	})
	local Content = require("portal.content")
	local Iterator = require("portal.iterator")
	local Portal = require("portal")

	local iter = Iterator:new(items)
	if opts.filter then
		iter = iter:filter(opts.filter)
	end
	if opts.map then
		iter = iter:map(opts.map)
	end
	iter = iter:map(function(v, _i)
		return Content:new({
			type = v.title or title,
			buffer = v.bufnr,
			cursor = { row = v.lnum, col = v.col },
			callback = callback,
		})
	end):take(opts.max_results)

	local res = {
		source = iter,
		slots = opts.slots,
	}
	Portal.tunnel(res)
end

local function portal_buffers(opts)
	opts = vim.tbl_deep_extend("keep", opts or {}, {
		max_results = 4,
	})
	local buffers = vim.api.nvim_list_bufs()
	local Content = require("portal.content")
	local Iterator = require("portal.iterator")
	local Portal = require("portal")

	local iter = Iterator:new(buffers)
		:filter(function(v)
			local mark = vim.api.nvim_buf_get_mark(v, ".")
			if mark[1] == 0 and mark[2] == 0 then
				return false
			end
			return vim.api.nvim_buf_get_option(v, "buflisted")
		end)
		:map(function(v, _i)
			-- get last edit location for buf
			local mark = vim.api.nvim_buf_get_mark(v, ".")
			return Content:new({
				type = "buffer",
				buffer = v,
				cursor = { row = mark[1], col = mark[2] },
				callback = function(content)
					local buf = content.buffer
					local cursor = content.cursor
					local win = vim.api.nvim_get_current_win()
					local bufnr = vim.api.nvim_win_get_buf(win)
					if buf ~= bufnr then
						vim.api.nvim_set_current_buf(buf)
					end
					local line = math.min(vim.api.nvim_buf_line_count(buf), cursor.row)
					vim.api.nvim_win_set_cursor(win, { line, cursor.col })
				end,
			})
		end)
		:take(opts.max_results)
	local res = {
		source = iter,
		slots = nil,
	}
	Portal.tunnel(res)
end

local function portal_diagnostics(opts)
	opts = vim.tbl_deep_extend("keep", opts or {}, {
		max_results = 4,
	})
	local diagnostics = vim.diagnostic.get(opts.buffer or nil)
	local Content = require("portal.content")
	local Iterator = require("portal.iterator")
	local Portal = require("portal")

	local iter = Iterator:new(diagnostics)
		:take(4)
		:map(function(v, _i)
			return Content:new({
				type = "diagnostics",
				buffer = v.bufnr,
				cursor = { row = v.lnum, col = 1 },
				extra = v.col,
				callback = function(content)
					local buf = content.buffer
					local cursor = content.cursor
					local win = vim.api.nvim_get_current_win()
					local bufnr = vim.api.nvim_win_get_buf(win)
					if buf ~= bufnr then
						vim.api.nvim_set_current_buf(buf)
					end
					vim.api.nvim_win_set_cursor(win, { cursor.row, content.extra })
				end,
			})
		end)
		:take(opts.max_results)
	local res = {
		source = iter,
		slots = nil,
	}
	Portal.tunnel(res)
end

local function portal_oldfiles()
	local scheme_guard = function(path)
		if path:match("%w+://") ~= nil then
			return path
		else
			return "file://" .. path
		end
	end
	local oldfiles = vim.v.oldfiles
	mkportal("oldfiles", oldfiles, function(content)
		local buf = content.buffer
		local cursor = content.cursor
		local win = vim.api.nvim_get_current_win()
		local bufnr = vim.api.nvim_win_get_buf(win)
		if buf ~= bufnr then
			vim.api.nvim_set_current_buf(buf)
		end
		local lcount = vim.api.nvim_buf_line_count(buf)
		if cursor.row > lcount then
			cursor.row = lcount
		end
		vim.api.nvim_win_set_cursor(win, { cursor.row, cursor.col })
	end, {
		filter = function(v)
			return vim.loop.fs_stat(v) ~= nil
		end,
		map = function(v)
			local bufnr = vim.uri_to_bufnr(scheme_guard(v))
			vim.fn.bufload(bufnr)

			local mark = vim.api.nvim_buf_get_mark(bufnr, ".")

			if mark[1] == 0 and mark[2] == 0 then
				mark = { 1, 0 }
			end
			return {
				title = "oldfiles",
				bufnr = bufnr,
				lnum = mark[1],
				col = mark[2],
			}
		end,
	})
end

local function portal_references(context)
	local params = vim.lsp.util.make_position_params()
	params.context = context or {
		includeDeclaration = true,
	}
	vim.lsp.buf_request(0, "textDocument/references", params, function(err, result)
		if err then
			vim.notify(err.message)
			return
		end
		if not result then
			vim.notify("no references found")
			return
		end
		local references = result
		mkportal("references", references, function(content)
			local buf = content.buffer
			local cursor = content.cursor
			local win = vim.api.nvim_get_current_win()
			local bufnr = vim.api.nvim_win_get_buf(win)
			if buf ~= bufnr then
				vim.api.nvim_set_current_buf(buf)
			end
			vim.api.nvim_win_set_cursor(win, { cursor.row + 1, cursor.col })
		end, {
			map = function(v)
				return {
					title = "references",
					bufnr = vim.uri_to_bufnr(v.uri),
					lnum = v.range.start.line,
					col = v.range.start.character,
				}
			end,
		})
	end)
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
	h = "help",
	v = "view",
	r = "misc",
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
			name = "Actions",
			a = "Code actions",
			m = {
				require("willothy.actions").quickmenu,
				"Actions menu",
			},
		},
	},
	b = {
		name = "buffer",
		l = {
			portal_buffers,
			"Portal buffers",
		},
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
		name = "line",
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
	j = (function()
		local portal = require("portal.builtin")
		return {
			name = "portal",
			d = { portal_diagnostics, "diagnostics" },
			r = { portal_references, "references" },
			o = { portal_oldfiles, "oldfiles" },
			b = {
				name = "buffer",
				d = {
					function()
						portal_diagnostics({ buffer = 0 })
					end,
					"diagnostics",
				},
				j = {
					util.bind(portal.jumplist.tunnel, {
						filter = function(v)
							return v.buffer == vim.api.nvim_get_current_buf()
						end,
					}),
					"buffer",
				},
			},
			j = { portal.jumplist.tunnel, "jumplist" },
			h = { portal.harpoon.tunnel, "harpoon" },
			q = { portal.quickfix.tunnel, "quickfix" },
			c = { portal.changelist.tunnel, "changelist" },
		}
	end)(),
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
	["<C-c>"] = { '"+y', "Copy selection" },
}, {
	mode = "v",
})
