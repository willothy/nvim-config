return {
	-- Color themes
	"rktjmp/shipwright.nvim",
	"folke/tokyonight.nvim",
	"olivercederborg/poimandres.nvim",
	"rktjmp/lush.nvim",
	{
		"willothy/minimus",
		dependencies = {
			"rktjmp/lush.nvim",
		},
		lazy = false,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
	},
}
