function Browse(target)
	if target == nil then
		target = vim.fn.getcwd()
	elseif type(target) == 'function' then
		target = target()
	end
	require('telescope').extensions.file_browser.file_browser({ cwd = target })
end

vim.api.nvim_create_user_command('Browse', function(args)
	local target
	if args and args["args"] then
		target = args["args"]
	else
		target = vim.fn.getcwd()
	end
	require('telescope').extensions.file_browser.file_browser({ cwd = target })
end, { nargs = "?" })

function Wrap(fn, ...)
	local arg = ...
	return function()
		return fn(arg)
	end
end

function GetParentPath(path)
	pattern1 = "^(.+)//"
	pattern2 = "^(.+)\\"

	if (string.match(path, pattern1) == nil) then
		return string.match(path, pattern2)
	else
		return string.match(path, pattern1)
	end
end

local M = {}

function M.bind(func, ...)
	local args = ...
	return function()
		func(args)
	end
end

function M.reload(plugin)
	if plugin == nil then
		plugin = "willothy.util"
	end
	for k, v in pairs(package.loaded) do
		if string.match(k, "^" .. plugin) then
			package.loaded[k] = nil
		end
	end
	return require(plugin)
end

function M.quickHarpoon()
	local Popup = require("nui.popup")
	local Layout = require("nui.layout")
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
			row = 0
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
		require('harpoon.ui').nav_file(line)
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
		popup:map("n", string.format("%d", i), M.bind(require("harpoon.ui").nav_file, i))
	end

	-- set content
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, qflines)

	vim.api.nvim_buf_set_option(popup.bufnr, 'modifiable', false)
	-- mount/open the component
	popup:mount()
end

return M
