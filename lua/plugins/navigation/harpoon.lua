return {
	{
		"ThePrimeagen/harpoon",
		lazy = true,
		event = "VeryLazy",
		config = function()
			require("harpoon").setup({
				global_settings = {
					tabline = false,
				},
			})
		end,
	},
}
