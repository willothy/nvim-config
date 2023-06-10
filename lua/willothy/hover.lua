local M = {}

local current = nil
local function on_hover(pos)
	if current and pos.screencol == current.screencol and pos.screenrow == current.screenrow then
		return
	end
	current = pos
	local statuscol_width = 4

	local win = vim.api.nvim_get_current_win()
	local win_pos = vim.api.nvim_win_get_position(win)
	local win_width = vim.api.nvim_win_get_width(win)
	local win_height = vim.api.nvim_win_get_height(win)

	function is_inside_window()
		return pos.screencol > win_pos[2]
			and pos.screencol <= win_pos[2] + win_width
			and pos.screenrow > win_pos[1]
			and pos.screenrow <= win_pos[1] + win_height
	end

	if is_inside_window() and pos.screencol <= win_pos[2] + statuscol_width then
		vim.print(pos.screencol .. ", " .. pos.screenrow)
	end
end

_G.cokeline.__handlers.move:register(on_hover)

return M
