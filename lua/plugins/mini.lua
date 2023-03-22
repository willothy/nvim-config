function HandleMiniDisable()
	---@diagnostic disable-next-line: param-type-mismatch
	local bufinfo = vim.fn.getbufinfo(vim.api.nvim_win_get_buf(0))
	if bufinfo == nil then
		return
	end
	local buf = bufinfo[0] or bufinfo[1]
	if buf == nil then
		return
	end

	local listed = buf.listed
	if listed == 0 and vim.bo.filetype ~= "alpha" then
		vim.b.minicursorword_disable = true
		vim.b.miniindentscope_disable = true
	else
		vim.b.minicursorword_disable = false
		vim.b.miniindentscope_disable = false
	end
end

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		HandleMiniDisable()
	end,
})

return {
	-- mini.nvim
	{
		"echasnovski/mini.jump",
		name = "mini.jump",
		version = false,
		lazy = true,
		event = "VeryLazy",
		config = function()
			require("mini.jump").setup({
				mappings = {
					backward_till = "",
					forward_till = "",
				},
			})
		end,
	},
	{
		"echasnovski/mini.indentscope",
		name = "mini.indentscope",
		version = false,
		lazy = true,
		event = "VeryLazy",
		config = function()
			require("mini.indentscope").setup({
				symbol = "▏",
			})
		end,
	},
	{
		"echasnovski/mini.cursorword",
		name = "mini.cursorword",
		version = false,
		lazy = true,
		event = "VeryLazy",
		config = function()
			require("mini.cursorword").setup()
		end,
	},
	{
		"echasnovski/mini.bracketed",
		name = "mini.bracketed",
		version = false,
		lazy = true,
		event = "VeryLazy",
		config = function()
			require("mini.bracketed").setup()
		end,
	},
}
