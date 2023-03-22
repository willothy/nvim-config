local function toggle_terminal()
	if vim.bo.filetype == "toggleterm" then
		require("toggleterm").toggle(0)
	elseif vim.bo.filetype == "nvterm" then
		require("nvterm").toggle("horizontal")
	end
end

return {
	{
		"willothy/flatten.nvim",
		dir = "~/projects/neovim/flatten/",
		opts = {
			callbacks = {
				pre_open = function()
					toggle_terminal()
				end,
				post_open = function(bufnr, winnr, ft, is_blocking)
					if ft == "gitcommit" then
						vim.api.nvim_create_autocmd("BufWritePost", {
							buffer = bufnr,
							once = true,
							callback = function()
								vim.defer_fn(function()
									vim.api.nvim_buf_delete(bufnr, {})
								end, 50)
							end,
						})
					elseif not is_blocking then
						toggle_terminal()
						vim.api.nvim_set_current_win(winnr)
					end
				end,
				block_end = function()
					toggle_terminal()
				end,
			},
			window = {
				open = "current",
			},
		},
		-- config = true
	},
}
