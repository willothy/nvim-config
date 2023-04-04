vim.api.nvim_create_augroup("TempBuf", { clear = true })

local function round(float)
	return math.floor(float + 0.5)
end

local ui = vim.api.nvim_list_uis()[1]

---@alias buffer integer
---@alias window integer

-- Configures a window
---@param conf table
local function window_config(conf)
	local col
	local row

	if type(conf.col) == "string" then
		if conf.col == "left" then
			col = 0
		elseif conf.col == "right" then
			col = ui.width - conf.width
		else
			col = (ui.width - conf.width) / 2
		end
	elseif type(conf.col) == "number" then
		col = conf.col
	else
		col = (ui.width - conf.width) / 2
	end

	if type(conf.row) == "string" then
		if conf.row == "top" then
			row = 0
		elseif conf.row == "bottom" then
			row = ui.height - conf.height
		else
			row = (ui.height - conf.height) / 2
		end
	elseif type(conf.row) == "number" then
		row = conf.row
	else
		row = (ui.height - conf.height) / 2
	end

	return {
		relative = conf.relative or "editor",
		width = conf.width,
		height = conf.height,
		col = col,
		row = row,
		focusable = conf.focusable ~= nil and conf.focusable or true,
		style = "minimal",
		border = "single",
	}
end

-- Opens a window with the given buffer
---@param bufnr number
---@param enter boolean
---@param config table
local function OpenWin(bufnr, enter, config)
	if type(enter) == "table" then
		config = enter
		enter = false
	end
	local window = vim.api.nvim_open_win(bufnr, enter, config)
	local autocmd
	autocmd = vim.api.nvim_create_autocmd("WinLeave", {
		group = "TempBuf",
		buffer = bufnr,
		callback = function()
			vim.api.nvim_win_close(window, true)
			vim.api.nvim_del_autocmd(autocmd)
		end,
	})
	return window
end

---@param bufnr number
---@param row number | string | nil
---@param col number | string | nil
---@param width number | nil
---@param height number | nil
local function WindowPopup(bufnr, row, col, width, height)
	if type(width) == "string" then
		width = round(ui.width * (width:gsub("%%", "") / 100))
	elseif type(width) == "number" then
		width = round(ui.width * (width / 100))
	else
		vim.notify(
			string.format("Could not open window: width is %s, expected percentage string or number", type(width)),
			"error"
		)
		return
	end

	if type(height) == "string" then
		height = round(ui.height * (height:gsub("%%", "") / 100))
	elseif type(height) == "number" then
		height = round(ui.height * (height / 100))
	else
		vim.notify(
			string.format("Could not open window: height is %s, expected percentage string or number", type(height)),
			"error"
		)
		return
	end
	width = width or round(ui.width * 0.25)
	height = height or round(ui.height * 0.25)
	local conf = window_config({
		width = width,
		height = height,
		col = col or ((ui.width - width) / 2),
		row = row or ((ui.height - height) / 2),
	})
	OpenWin(bufnr, true, conf)
end

---@param bufnr number
local function CursorPopup(bufnr)
	local conf = window_config({
		width = 10,
		height = 5,
		row = 0,
		col = 0,
		relative = "cursor",
	})
	OpenWin(bufnr, true, conf)
end

-- Creates a temporary buffer with the given string or lines
---@param contents string | table
---@return integer|buffer
local function TempBufWith(contents)
	local bufnr = vim.api.nvim_create_buf(true, false)
	local lines = {}
	if type(contents) == "table" then
		lines = contents
	else
		for line in contents:gmatch("([^\n]*)\n?") do
			table.insert(lines, line)
		end
	end
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
	vim.api.nvim_create_autocmd("BufLeave", {
		group = "TempBuf",
		buffer = bufnr,
		callback = function()
			vim.api.nvim_buf_delete(bufnr, { force = true })
			--buffer_number = -1
		end,
	})
	return bufnr
end

-- Gets LSP info and displays it in a temporary buffer
---@return nil
local function GetLSPInfo()
	local lsp = vim.inspect(vim.lsp.get_active_clients())
	local lines = {}
	for line in lsp:gmatch("([^\n]*)\n?") do
		table.insert(lines, line)
	end
	WindowPopup(TempBufWith(lines), "top", "center", "70%", "70%")
end

-- This doesn't work!
local function quickHarpoon()
	local Popup = require("nui.popup")
	-- local Layout = require("nui.layout")
	local event = require("nui.utils.autocmd").event

	require("harpoon.mark").to_quickfix_list()
	local qf = vim.fn.getqflist()
	local count = #qf
	local maxlen = 0

	local qflines = {}
	for i, v in ipairs(qf) do
		qflines[#qflines + 1] = " " .. v.text
		local len = #v.text + 1
		if len > maxlen then
			maxlen = len
		end
		if i > 4 then
			break
		end
	end

	local popup = Popup({
		enter = true,
		focusable = true,
		relative = "cursor",
		border = {
			style = "rounded",
		},
		position = {
			col = 0,
			row = 0,
		},
		size = {
			width = maxlen + 1,
			height = math.min(count, 5),
		},
		buf_options = {
			modifiable = true,
			readonly = false,
		},
	})

	-- vim.api.nvim_exec("mapclear " .. popup.bufnr, true)

	local nav_to_line = function(bufnr)
		local line = vim.api.nvim_win_get_cursor(0)[1]
		require("harpoon.ui").nav_file(line)
	end

	-- unmount component when cursor leaves buffer
	popup:on(event.BufLeave, function()
		-- popup:unmount()
		popup:unmount()
	end)

	popup:map("n", "<esc>", function(bufnr)
		popup:unmount()
	end, { noremap = true })
	popup:map("n", "q", function(bufnr)
		popup:unmount()
	end, { noremap = true })
	popup:map("n", "<space>", nav_to_line)
	popup:map("n", "<CR>", nav_to_line)

	for i, _ in ipairs(qflines) do
		popup:map("n", string.format("%d", i), require("willothy.util").bind(require("harpoon.ui").nav_file, i))
	end

	-- set content
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, qflines)

	vim.api.nvim_buf_set_option(popup.bufnr, "modifiable", false)
	-- mount/open the component
	popup:mount()
end
