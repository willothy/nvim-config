local function setup()
	vim.keymap.set("n", "<leader>gs", vim.cmd.Git, {
		desc = "Open git fugitive",
	})
end

return { {
	'tpope/vim-fugitive',
	init = setup
} }
