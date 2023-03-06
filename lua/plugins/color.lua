return {
	-- Color themes
	'connorholyday/vim-snazzy',
	'AlexvZyl/nordic.nvim',
	'olivercederborg/poimandres.nvim',
	'rktjmp/lush.nvim',
	{
		dir = '~/projects/lua/minimus/',
		dependencies = {
			'rktjmp/lush.nvim'
		},
		config = function()
			require("lush")(require("minimus"))
		end,
		lazy = false,
	},
	{
		'catppuccin/nvim',
		name = 'catppuccin'
	},
	-- 'xiyaowong/nvim-transparent',
}
