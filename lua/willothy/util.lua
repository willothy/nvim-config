local M = {}

---@param target string | fun():string
function M.browse(target)
	if target == nil then
		target = vim.fn.getcwd()
	elseif type(target) == "function" then
		target = target()
	end
	require("telescope").extensions.file_browser.file_browser({ cwd = target })
end

function M.is_root(pathname)
	if string.sub(package["config"], 1, 1) == "\\" then
		return string.match(pathname, "^[A-Z]:\\?$")
	end
	return pathname == "/"
end

function M.project_root()
	local Path = require("plenary.path")
	local path = Path:new(vim.fn.expand("%"))
	while not M.is_root(path) do
		if path:joinpath(".git"):exists() then
			return path
		else
			path = path:parent()
		end
	end
	return nil
end

function M.crate_root()
	local Path = require("plenary.path")
	local path = Path:new(vim.fn.expand("%"))
	while not M.is_root(path) do
		if path:joinpath("Cargo.toml"):exists() then
			return path
		else
			path = path:parent()
		end
	end
	vim.notify("Not in a Rust crate")
	return nil
end

function M.parent_crate()
	local root = M.crate_root()
	if root == nil then
		return
	end
	local parent = M.crate_root(root .. "../")
	if parent == nil then
		vim.notify("No parent crate found")
	end
	return parent
end

function M.open_project_toml()
	local root = M.crate_root()
	if root == nil then
		return
	end
	vim.api.nvim_command("edit " .. string.format("%s", root) .. "/Cargo.toml")
end

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

return M
