return { {
	"samjwill/nvim-unception",
	config = function()
		vim.g.unception_open_buffer_in_new_tab = true
	end,
	init = function()
		vim.api.nvim_create_autocmd(
			"User",
			{
				pattern = "UnceptionEditRequestReceived",
				callback = function()
					-- Toggle the terminal off.
					require('toggleterm').toggle(0)
					local autoenter
					autoenter = vim.api.nvim_create_autocmd("BufEnter", {
						pattern = "*",
						callback = function()
							-- Toggle the terminal back on.
							local winnr = vim.api.nvim_get_current_win()
							require('toggleterm').toggle(0)
							vim.api.nvim_set_current_win(winnr)
							vim.api.nvim_del_autocmd(autoenter)
						end
					})
				end
			}
		)
	end
} }
