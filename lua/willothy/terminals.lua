local M = {}

local Terminal = require("toggleterm.terminal").Terminal

M.float = Terminal:new({
	display_name = "floating",
	cmd = "zsh",
	hidden = false,
	direction = "float",
	float_opts = {
		border = "rounded",
	},
	-- on_open = function(term)
	-- 	vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
	-- end,
})

M.main = Terminal:new({
	display_name = "main",
	cmd = "zsh",
	hidden = false,
	direction = "horizontal",
	on_open = function(term)
		vim.cmd("startinsert!")
	end,
})

M.py = Terminal:new({
	cmd = "python3",
	hidden = true,
})

M.lua = Terminal:new({
	cmd = "lua",
	hidden = true,
})

local cargo_run = Terminal:new({
	cmd = "cargo run",
	hidden = true,
	close_on_exit = true,
})
M.cargo_run = cargo_run

local cargo_test = Terminal:new({
	cmd = "cargo test",
	hidden = true,
	close_on_exit = true,
})
M.cargo_test = cargo_test

return M
