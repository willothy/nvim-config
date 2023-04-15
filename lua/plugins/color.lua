return {
	-- Color themes
	"rktjmp/shipwright.nvim",
	"folke/tokyonight.nvim",
	"olivercederborg/poimandres.nvim",
	{
		"rktjmp/lush.nvim",
		cond = true,
	},
	{
		"willothy/minimus",
		dir = "~/projects/lua/minimus/",
		dependencies = {
			"rktjmp/lush.nvim",
		},
		lazy = false,
		cond = true,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
	},
}
