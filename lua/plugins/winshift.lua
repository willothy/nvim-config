return {
	{
		'sindrets/winshift.nvim',
		config = true,
		lazy = true,
		event = 'VeryLazy',
		init = function()
			vim.keymap.set("n", "<C-w>w", function()
				vim.api.nvim_exec("WinShift", true)
			end, {
				desc = "Enter WinShift mode"
			})
			vim.keymap.set("n", "<C-w>x", function()
				vim.api.nvim_exec("WinShift swap", true)
			end, {
				desc = "Swap windows"
			})
		end
	}
}
