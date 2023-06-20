return {
	{
		"dreamsofcode-io/ChatGPT.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		lazy = true,
		event = "VeryLazy",
		enabled = false,
		config = function()
			require("chatgpt").setup({
				async_api_key_cmd = "lpass show --password openai_key",
			})
		end,
	},
}
