local function setup()
	local mark = require("harpoon.mark")
	local ui = require("harpoon.ui")

	vim.keymap.set("n", "<leader>a", mark.add_file, {
		desc = "Add file to harpoon",
	})
	vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu, {
		desc = "Toggle harpoon quick menu",
	})
end

return { {
	-- 'theprimeagen/harpoon',
	'willothy/harpoon',
	init = setup
} }
