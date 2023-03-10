return { {
	"samjwill/nvim-unception",
	config = function()
		vim.g.unception_open_buffer_in_new_tab = true
	end,
	enabled = false,
	init = function()
		vim.api.nvim_create_autocmd(
			"User",
			{
				pattern = "UnceptionEditRequestReceived",
				callback = function()
					-- Toggle the terminal off.
					require('toggleterm').toggle(0)

					-- vim.api.nvim_create_autocmd("BufEnter", {
					-- 	pattern = "*",
					-- 	once = true,
					-- 	callback = function()
					-- 		-- Toggle the terminal back on.
					-- 		local winnr = vim.api.nvim_get_current_win()
					-- 		local bufnr = vim.api.nvim_get_current_buf()
					--
					-- 		local ft = vim.bo.filetype
					-- 		if ft == "gitcommit" then
					-- 			vim.api.nvim_create_autocmd("BufWritePost", {
					-- 				buffer = bufnr,
					-- 				once = true,
					-- 				callback = function()
					-- 					
					-- 					vim.api.nvim_buf_delete(bufnr, {})
					-- 					-- require('toggleterm').toggle(0)
					-- 				end
					-- 			})
					-- 		else
					-- 			require('toggleterm').toggle(0)
					-- 			vim.api.nvim_set_current_win(winnr)
					-- 		end
					-- 	end
					-- })
				end
			}
		)
	end
} }
