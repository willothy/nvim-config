local function setup()
	local moveline = require("moveline")

	vim.keymap.set("n", "<M-j>", moveline.down, {
		desc = "Move line down",
	})
	vim.keymap.set("n", "<M-k>", moveline.up, {
		desc = "Move line up",
	})

	vim.keymap.set("v", "<M-k>", moveline.block_up, {
		desc = "Move block up",
	})
	vim.keymap.set("v", "<M-j>", moveline.block_down, {
		desc = "Move block down",
	})
end

-- Moveline
return { {
	'willothy/moveline.nvim',
	-- dir = '~/projects/neovim/moveline/',
	build = 'make',
	config = setup,
	lazy = false,
} }
