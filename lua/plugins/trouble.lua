local function setup()
	vim.keymap.set("n", "T", ":TroubleToggle document_diagnostics<CR>")
end

return { {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	lazy = true,
	config = setup,
	-- config = true,
} }
