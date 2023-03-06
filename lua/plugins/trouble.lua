local function setup()
	vim.keymap.set("n", "T", "<Cmd>TroubleToggle document_diagnostics<CR>", {
		desc = "Toggle trouble",
	})
end

return { {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	init = setup,
	config = true,
} }
