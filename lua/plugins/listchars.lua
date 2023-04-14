return {
	{
		"fraso-dev/nvim-listchars",
		init = function()
			vim.opt.list = true
		end,
		config = function()
			require("nvim-listchars").setup({
				save_state = false,
				listchars = {
					trail = "-",
					eol = "↲",
					tab = "» ",
				},
				exclude_filetypes = {
					"markdown",
				},
				lighten_step = 10,
			})
		end,
	},
}
