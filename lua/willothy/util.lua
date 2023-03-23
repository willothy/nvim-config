local M = {}

function M.browse(target)
	if target == nil then
		target = vim.fn.getcwd()
	elseif type(target) == "function" then
		target = target()
	end
	require("telescope").extensions.file_browser.file_browser({ cwd = target })
end

function M.is_root(pathname)
	if package.config:sub(1, 1) == "\\" then
		return string.match(pathname, "^[A-Z]:\\?$")
	end
	return pathname == "/"
end

-- WIP
-- local function find_crate_root(path)
-- 	local Path = require("plenary.path")
-- 	local dir = path and Path:new(path) or Path:new(vim.fn.expand("%")):parent()
--
-- 	while #dir:_split() > 2 do
-- 		if dir:joinpath("Cargo.toml"):exists() then
-- 			return dir
-- 		else
-- 			dir = dir:parent()
-- 		end
-- 	end
-- 	return nil
-- end
--
-- function M.parent_crate()
-- 	local Path = require("plenary.path")
-- 	local root = find_crate_root()
-- 	if root == nil then
-- 		return
-- 	end
-- 	local parent = find_crate_root(root .. "../")
-- 	if parent == nil then
-- 		return
-- 	else
-- 		local p = string.format("%s", parent)
-- 		Browse(p)
-- 	end
-- end
--
-- function M.open_cargo_toml()
-- 	local Path = require("plenary.path")
-- 	local root = find_crate_root()
-- 	if root == nil then
-- 		return
-- 	end
--
-- 	vim.api.nvim_command("edit " .. string.format("%s", root) .. "/Cargo.toml")
-- end
--
-- function BrowseCrateRoot()
-- 	local Path = require("plenary.path")
-- 	local root = find_crate_root()
-- 	if root == nil then
-- 		return
-- 	end
--
-- 	Browse("" .. root)
-- end

vim.api.nvim_create_user_command("Browse", function(args)
	local target
	if args and args["args"] then
		target = args["args"]
	else
		target = vim.fn.getcwd()
	end
	require("telescope").extensions.file_browser.file_browser({ cwd = target })
end, { nargs = "?" })

function M.get_parent_path(path)
	local pattern1 = "^(.+)//"
	local pattern2 = "^(.+)\\"

	if string.match(path, pattern1) == nil then
		return string.match(path, pattern2)
	else
		return string.match(path, pattern1)
	end
end

function M.bind(func, ...)
	local args = ...
	return function()
		func(args)
	end
end

function M.reload(plugin_name)
	if plugin_name == nil then
		return
	end
	local plugin = require("lazy.core.config").plugins[plugin_name]
	if plugin == nil then
		print("Plugin " .. plugin_name .. " was not found")
		return require(plugin_name)
	end
	require("lazy.core.loader").reload(plugin)
	local p = require(plugin_name)
	require("lazy.core.config").plugins[plugin_name]:config()
	return p
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
		popup:map("n", string.format("%d", i), M.bind(require("harpoon.ui").nav_file, i))
	end

	-- set content
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, qflines)

	vim.api.nvim_buf_set_option(popup.bufnr, "modifiable", false)
	-- mount/open the component
	popup:mount()
end

return M
