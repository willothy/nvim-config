return { {
	'tamton-aquib/flirt.nvim',
	opts = {
		override_open = false,
		default_move_mappings = true,
		default_resize_mappings = true,
		default_mouse_mappings = false,
	},
	-- init = function()
	-- 	local w, r, c, is_popup
	-- 	local width, height
	-- 	vim.keymap.set('n', '<LeftDrag>', function()
	-- 		local info = vim.fn.getmousepos()
	-- 		if not is_popup then
	-- 			if vim.fn.win_gettype(info.winid) == "popup" then
	-- 				is_popup = true
	-- 			else
	-- 				is_popup = false
	-- 			end
	-- 		end
	--
	-- 		if not w then
	-- 			w = info.winid
	-- 			r = info.winrow
	-- 			c = info.wincol
	-- 		end
	--
	-- 		if is_popup then
	-- 			local cfg = vim.api.nvim_win_get_config(w)
	-- 			cfg["row"][false] = info.screenrow - r
	-- 			cfg["col"][false] = info.screencol - c
	-- 			vim.api.nvim_win_set_config(w, cfg)
	-- 		else
	-- 			-- Handle non popup resize
	-- 			local curr_width = vim.api.nvim_win_get_width(w)
	-- 			local curr_height = vim.api.nvim_win_get_height(w)
	--
	-- 			local dy = info.screenrow > r and 1 or -1
	-- 			local dx = info.screencol > c and 2 or -1
	--
	-- 			vim.api.nvim_notify("r: " .. r .. ', ' .. 'h: ' .. curr_height, 3, {})
	-- 			if (c >= curr_width - 2 and c <= curr_width + 2) then
	-- 				vim.api.nvim_win_set_width(w, info.screencol + dx)
	-- 				c = info.screencol
	-- 			elseif r >= curr_height - 1 and r <= curr_height + 1 then
	-- 				vim.api.nvim_win_set_height(w, info.screenrow + dy)
	-- 				r = info.screenrow + (dy > 0 and 0 or -1)
	-- 			end
	-- 		end
	-- 	end, {})
	--
	-- 	vim.keymap.set({ 'n', 'v', 'i' }, '<LeftRelease>', function()
	-- 		if is_popup then
	-- 			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, true, true), 'n', true)
	-- 		else
	-- 		end
	-- 		w = nil
	-- 		is_popup = nil
	-- 	end, {})
	-- end
} }
