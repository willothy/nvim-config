return {
	-- Color themes
	"olivercederborg/poimandres.nvim",
	"rktjmp/lush.nvim",
	{
		"willothy/minimus",
		dependencies = {
			"rktjmp/lush.nvim",
		},
		config = function()
			require("lush")(require("minimus"))
		end,
		lazy = false,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
	},
}
