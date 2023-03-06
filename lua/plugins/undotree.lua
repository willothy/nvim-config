local function setup()
	vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, {
		desc = "Toggle undotree",
	})
end

return { {
	'mbbill/undotree',
	config = setup
} }
