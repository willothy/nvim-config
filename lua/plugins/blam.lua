return {
	'willothy/blam.nvim',
	build = 'make',
	config = true,
	init = function()
		vim.keymap.set("n", "<leader>b", require("blam").peek, {
			desc = "Peek line blame",
		})
	end,
}
