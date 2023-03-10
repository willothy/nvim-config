return { {
	'willothy/flatten.nvim',
	-- dir = '~/projects/lua/flatten/',
	opts = {
		callbacks = {
			pre_open = function()
				require("toggleterm").toggle(0)
			end,
			post_open = function(bufnr, winnr, ft)
				if ft == "gitcommit" then
					vim.api.nvim_create_autocmd("BufWritePost", {
						buffer = bufnr,
						once = true,
						callback = function()
							vim.api.nvim_buf_delete(bufnr, {
								unload = true
							})
							vim.defer_fn(function()
								vim.api.nvim_buf_delete(bufnr, {})
							end, 50)
						end
					})
				else
					require("toggleterm").toggle(0)
					vim.api.nvim_set_current_win(winnr)
				end
			end,
			block_end = function()
				require("toggleterm").toggle(0)
			end
		}
	},
} }
