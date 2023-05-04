local function toggle_terminal()
	if vim.bo.filetype == "toggleterm" then
		require("toggleterm").toggle(0)
	elseif vim.bo.filetype == "terminal" then
		require("nvterm.terminal").toggle("horizontal")
	end
end

return {
	{
		"willothy/flatten.nvim",
		-- dir = vim.g.dev == "flatten" and "~/projects/lua/flatten/" or nil,
		dir = "~/projects/lua/flatten/",
		cond = true,
		opts = {
			window = {
				open = "alternate",
			},
			-- nest_if_no_args = true,
			callbacks = {
				should_block = function(argv)
					-- If the first argument is "git", block
					for _, arg in ipairs(argv) do
						if arg == "-b" then
							return true
						end
					end
					return false
				end,
				post_open = function(bufnr, winnr, ft, is_blocking)
					if is_blocking or ft == "gitcommit" then
						-- Hide the terminal while it's blocking
						-- toggle_terminal()
						require("nvterm.terminal").hide("horizontal")
					else
						-- If it's a normal file, just switch to its window
						vim.api.nvim_set_current_win(winnr)
					end

					-- If the file is a git commit, create one-shot autocmd to delete its buffer on write
					-- If you just want the toggleable terminal integration, ignore this bit
					if ft == "gitcommit" then
						vim.api.nvim_create_autocmd("BufWritePost", {
							buffer = bufnr,
							once = true,
							callback = function()
								-- This is a bit of a hack, but if you run bufdelete immediately
								-- the shell can occasionally freeze
								vim.defer_fn(function()
									vim.api.nvim_buf_delete(bufnr, {})
								end, 50)
							end,
						})
					end
				end,
				block_end = function()
					-- After blocking ends (for a git commit, etc), reopen the terminal
					vim.defer_fn(function()
						require("nvterm.terminal").show("horizontal")
					end, 50)
				end,
			},
		},
	},
}
