local function setup()
	vim.keymap.set("n", "<leader>t", function()
		-- require("toggleterm").toggle()
		vim.api.nvim_exec("ToggleTerm direction=horizontal size=15", true)
	end, {
		desc = "Toggle terminal",
	})
end

return { {
	-- terminal
	"akinsho/toggleterm.nvim",
	init = setup,
	config = true,
} }
