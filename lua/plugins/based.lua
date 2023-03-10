return { {
	'trmckay/based.nvim',
	opts = {
		highlight = "LspInlayHint"
	},
	init = function()
		vim.api.nvim_create_user_command("Based", require('based').convert, {})
	end
} }
