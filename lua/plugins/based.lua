return {
	{
		"trmckay/based.nvim",
		opts = {
			highlight = "LspInlayHint",
		},
		lazy = true,
		cmd = "Based",
		init = function()
			vim.api.nvim_create_user_command("Based", require("based").convert, {})
		end,
	},
}
