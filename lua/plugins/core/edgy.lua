return {
	{
		"folke/edgy.nvim",
		event = "VeryLazy",
		opts = {
			bottom = {
				{
					ft = "Trouble",
					title = "Diagnostics",
					--      pinned = true,
					-- open = function()
					-- 	require("trouble").open()
					-- end,
				},
				{
					ft = "toggleterm",
					title = "Terminal",
					pinned = true,
					open = function()
						require("willothy.terminals").main:open()
					end,
				},
			},

			exit_when_last = true,

			animate = {
				enabled = true,
				fps = 60,
				cps = 180,
			},
		},
	},
}
