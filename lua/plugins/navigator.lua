return {
	{
		"numToStr/Navigator.nvim",
		config = true,
		enabled = false,
	},
	{
		"mrjones2014/smart-splits.nvim",
		-- config = true,
		lazy = false,
		opts = {
			multiplexer_integration = "wezterm",
		},
		enabled = true,
		-- event = "VimEnter",
	},
}
