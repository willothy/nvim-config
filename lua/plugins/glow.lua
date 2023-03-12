return { --[[ {
	"ellisonleao/glow.nvim",
	config = function()
		require("glow").setup({
			install_path = "~/go/bin"
		})
	end,
	enabled = false,
	lazy = true,
	event = "VeryLazy"
} ]] }
