return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"rouge8/neotest-rust",
		},
		lazy = true,
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-rust"),
				},
				summary = {
					enabled = true,
				},
				diagnostic = {
					enabled = true,
					severity = 1,
				},
				status = {
					enabled = true,
					virtual_text = true,
					signs = false,
				},
			})
		end,
	},
}
