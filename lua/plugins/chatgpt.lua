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
		enabled = false,
		opts = {
			keymaps = {
				submit = "<Enter>",
			},
		},
	},
}
