local icons = require("willothy.icons").diagnostics

return {
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = true,
		opts = {
			signs = {
				error = icons.error,
				warning = icons.warning,
				hint = icons.hint,
				information = icons.info,
			},
			track_cursor = true,
			padding = false,
		},
	},
}
