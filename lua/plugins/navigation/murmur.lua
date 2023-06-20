local murmur_group = "willothy_murmur"
vim.api.nvim_create_augroup(murmur_group, { clear = true })

local enabled = false

local function matchstr(...)
	local ok, ret = pcall(vim.fn.matchstr, ...)
	if ok then
		return ret
	end
	return ""
end

-- vim.api.nvim_create_user_command("DiagFloatToggle", function()
-- 	enabled = not enabled
-- end, {})
--
-- vim.api.nvim_create_autocmd({ "CursorMoved", "CursorHold" }, {
-- 	callback = function()
-- 		if enabled then
-- 			local column = vim.api.nvim_win_get_cursor(0)[2] + 1 -- one-based indexing.
-- 			local line = vim.api.nvim_get_current_line()
--
-- 			-- get the cursor word.
-- 			-- \k are chars that can be keywords.
-- 			local left = matchstr(line:sub(1, column), [[\k*$]])
-- 			local right = matchstr(line:sub(column), [[^\k*]]):sub(2)
--
-- 			local cursor_word = left .. right
-- 			if cursor_word == "" then
-- 				vim.cmd("doautocmd InsertEnter")
-- 				return
-- 			end
--
-- 			local _b, _w = vim.diagnostic.open_float(nil, {
-- 				focus = true,
-- 				scope = "cursor",
-- 				noautocmd = true,
-- 				anchor = "NW",
-- 			})
-- 		end
-- 	end,
-- })

return {
	-- {
	-- 	"nyngwang/murmur.lua",
	-- 	config = function()
	-- 		require("murmur").setup({
	-- 			-- cursor_rgb = {
	-- 			--  guibg = '#393939',
	-- 			-- },
	-- 			-- cursor_rgb_always_use_config = false, -- if set to `true`, then always use `cursor_rgb`.
	-- 			-- yank_blink = {
	-- 			--   enabled = true,
	-- 			--   on_yank = nil, -- Can be customized. See `:h on_yank`.
	-- 			-- },
	-- 			max_len = 80,
	-- 			min_len = 3, -- this is recommended since I prefer no cursorword highlighting on `if`.
	-- 			exclude_filetypes = {},
	-- 			callbacks = {
	-- 				-- to trigger the close_events of vim.diagnostic.open_float.
	-- 				function()
	-- 					-- Close floating diag. and make it triggerable again.
	-- 					vim.cmd("doautocmd InsertEnter")
	-- 					vim.w.diag_shown = false
	-- 					-- vim.diagnostic.open_float()
	-- 					-- vim.notify("callback", vim.log.levels.INFO, { title = "murmur" })
	-- 				end,
	-- 			},
	-- 		})
	--
	-- 		-- To create IDE-like no blinking diagnostic message with `cursor` scope. (should be paired with the callback above)
	-- 		vim.api.nvim_create_autocmd({ "CursorHold" }, {
	-- 			group = murmur_group,
	-- 			pattern = "*",
	-- 			callback = function()
	-- 				-- skip when a float-win already exists.
	-- 				if vim.w.diag_shown then
	-- 					-- vim.cmd("doautocmd InsertEnter")
	-- 					-- vim.diagnostic.open_float()
	-- 					return
	-- 				end
	--
	-- 				-- open float-win when hovering on a cursor-word.
	-- 				if vim.w.cursor_word ~= "" then
	-- 					vim.diagnostic.open_float()
	-- 					vim.w.diag_shown = true
	-- 				end
	-- 			end,
	-- 		})
	--
	-- 		-- To create special cursorword coloring for the colortheme `typewriter-night`.
	-- 		-- remember to change it to the name of yours.
	-- 		vim.api.nvim_create_autocmd({ "ColorScheme" }, {
	-- 			group = murmur_group,
	-- 			pattern = "typewriter-night",
	-- 			callback = function()
	-- 				vim.api.nvim_set_hl(0, "murmur_cursor_rgb", { fg = "#0a100d", bg = "#ffee32" })
	-- 			end,
	-- 		})
	-- 	end,
	-- },
}
