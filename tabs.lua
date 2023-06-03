local function get_tab_wins(tabpage)
	local wins = vim.api.nvim_tabpage_list_wins(tabpage)
	return vim.tbl_filter(function(v)
		local buf = vim.api.nvim_win_get_buf(v)
		local bt = vim.api.nvim_buf_get_option(buf, "buftype")
		return (bt == "" or bt == "terminal") and vim.api.nvim_buf_get_option(buf, "bufhidden") == ""
	end, wins)
end

local v = get_tab_wins(vim.api.nvim_get_current_tabpage())
print(v)
