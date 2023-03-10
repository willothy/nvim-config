return { --[[ {
	'nyngwang/murmur.lua',
	config = function()
		require('murmur').setup({
			-- max_len = 80,
			-- min_len = 3,
			-- exclude_filetypes = {
			-- 	"alpha",
			-- 	"gitcommit",
			-- },
			-- yank_blink = {
			-- 	enabled = false,
			-- },
			callbacks = {
				function()
					vim.cmd('doautocmd InsertEnter')
					vim.w.diag_shown = false
				end
			}
		})

		vim.api.nvim_create_autocmd({ 'CursorHold' }, {
			pattern = '*',
			callback = function()
				if vim.w.diag_shown then return end

				-- open float-win when hovering on a cursor-word.
				if vim.w.cursor_word ~= '' then
					vim.diagnostic.open_float()
					vim.w.diag_shown = true
					-- holdset = true
				end
			end
		})
	end
} ]] }
