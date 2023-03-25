return {
	{
		"jackMort/ChatGPT.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		lazy = true,
		cmd = "ChatGPT",
		opts = {
			keymaps = {
				submit = "<Enter>",
			},
		},
	},
}
