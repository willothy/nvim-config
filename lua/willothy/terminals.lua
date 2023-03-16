local M = {}

local Terminal = require('toggleterm.terminal').Terminal

local pyterm = Terminal:new({
	cmd = "python3",
	hidden = true,
})
M.py = pyterm

local luaterm = Terminal:new({
	cmd = "lua",
	hidden = true,
})
M.lua = luaterm

local cargo_run = Terminal:new({
	cmd = "cargo run",
	hidden = true,
	close_on_exit = true
})
M.cargo_run = cargo_run

local cargo_test = Terminal:new({
	cmd = "cargo test",
	hidden = true,
	close_on_exit = true
})
M.cargo_test = cargo_test

return M
