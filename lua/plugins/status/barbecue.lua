local icons = require("willothy.icons")

return {
	{
		"utilyre/barbecue.nvim",
		dependencies = {
			"SmiteshP/nvim-navic",
		},
		enabled = false,
		config = function()
			require("barbecue").setup({
				attach_navic = true,
				theme = "minimus",
				show_modified = true,
				exclude_filetypes = {
					"gitcommit",
					"toggleterm",
					"Glance",
					"mason",
					"alpha",
				},
				modified = function()
					return true
				end,
				symbols = {
					separator = icons.separators.angle_quote.right,
					modified = icons.kinds.Package,
				},
				kinds = require("willothy.icons").kinds,
			})
		end,
	},
}
