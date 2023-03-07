return {
	{
		"folke/which-key.nvim",
		dependencies = {
			'mrjones2014/legendary.nvim',
		},
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
			require("which-key").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
				operators = {},
				key_labels = {
					["<space>"] = "SPC",
					["<cr>"] = "RET",
					["<tab>"] = "TAB",
				}
			})
		end,
	},
	{
		'mrjones2014/legendary.nvim',
		tag = 'v2.1.0',
		dependencies = {
			'kkharji/sqlite.lua',
			"folke/which-key.nvim",
		},
		config = function()
			require('legendary').setup({
				which_key = {
					auto_register = true
				}
			})
		end
	}
}
