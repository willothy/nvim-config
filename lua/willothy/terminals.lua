local M = {}

local Terminal = require("toggleterm.terminal").Terminal

M.float = Terminal:new({
	display_name = "floating",
	filetype = "toggleterm_float",
	cmd = "zsh",
	hidden = false,
	direction = "float",
	float_opts = {
		border = "rounded",
	},
	close_on_exit = true,
})

M.main = Terminal:new({
	display_name = "main",
	cmd = "zsh",
	hidden = false,
	close_on_exit = true,
	direction = "horizontal",
	on_create = function(t)
		local group = vim.api.nvim_create_augroup("term_autosize", { clear = true })
		local buf = t.bufnr
		vim.api.nvim_create_autocmd("TermEnter", {
			buffer = buf,
			group = group,
			callback = function()
				vim.api.nvim_win_set_height(t.window, vim.o.lines / 2)
				local win = require("edgy").get_win(t.window)
				if win then
					-- expand window vertically
					win.height = vim.o.lines / 2
					win:resize()
				end
				-- t:resize(vim.o.lines / 2)
			end,
		})
		vim.api.nvim_create_autocmd("BufLeave", {
			buffer = buf,
			group = group,
			callback = function()
				vim.api.nvim_win_set_height(t.window, 4)
				local win = require("edgy").get_win(t.window)
				if win then
					-- expand window vertically
					win.height = 4
					win:resize()
				end
				-- t:resize(3)
			end,
		})
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

function M.with()
	local term = require("willothy.terminals").main
	local win = require("edgy").get_win(term.window)
	if term:is_open() then
		if win and not win.visible then
			win:open()
		end
	else
		term:open()
	end
	return term
end

function M.with_float()
	local term = require("willothy.terminals").float
	local win = require("edgy").get_win(term.window)
	if term:is_open() then
		if win and not win.visible then
			win:open()
		end
	else
		term:open()
	end
	return term
end

function M.toggle()
	local term = require("willothy.terminals").main
	local win = require("edgy").get_win(term.window)
	if term:is_open() then
		if win and win.visible then
			win:close()
		elseif win then
			win:open()
		end
	else
		term:open()
	end
end

function M.toggle_float()
	M.float:toggle()
end

return M
