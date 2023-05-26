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

function M.find_root(markers)
	local Path = require("plenary.path")
	local last
	local path = Path:new(vim.fn.expand("%"))
	while path ~= last and not M.is_root(path) do
		-- for _, marker in ipairs(markers) do
		-- end
		if path:joinpath(".git"):exists() then
			return path
		end
		last = path
		path = path:parent()
	end
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
	return function(...)
		func(args, ...)
	end
end

function M.reload(mod)
	package.loaded[mod] = nil
	return require(mod)
end

function M.current_mod()
	return string.gsub(
		vim.fn.expand("%:p:r:s?" .. vim.fn.stdpath("config") .. "/lua/??"),
		string.sub(package["config"], 1, 1),
		"."
	)
end

vim.api.nvim_create_user_command("Reload", function(args)
	if args and args["args"] ~= "" then
		M.reload(args["args"])
	else
		M.reload(M.current_mod())
	end
end, { nargs = "?" })

function M.list_bufs()
	local bufs = vim.api.nvim_list_bufs()
	local buf_list = {}
	for _, buf in ipairs(bufs) do
		local name = vim.api.nvim_buf_get_name(buf)
		if name ~= "" then
			table.insert(buf_list, name)
		end
	end
	return buf_list
end

vim.api.nvim_create_user_command("Bd", function()
	require("bufdelete").bufdelete(0, true)
end, {})

vim.api.nvim_create_user_command("LuaAttach", function()
	require("luapad").attach()
end, {})

vim.api.nvim_create_user_command("LuaDetach", function()
	require("luapad").detach()
end, {})

function M.longest_line(lines)
	local longest = 0
	for _, line in ipairs(lines) do
		local len = string.len(line)
		if len > longest then
			longest = len
		end
	end
	return longest
end

function M.create_float(lines, lang)
	local longest = M.longest_line(lines)
	local win_width = vim.api.nvim_win_get_width(0)
	vim.lsp.util.open_floating_preview(lines, lang or "markdown", {
		height = #lines,
		width = longest > win_width and win_width or longest,
		focus = false,
		border = "rounded",
	})
end

function M.is_pascal_case(str)
	return str:match("^%u%w+$") ~= nil and not str:gmatch("_")()
end

---@param string string
---@param case "snake"|"SNAKE"|"camel"|"Pascal"
local function do_make_case(s, case)
	words = {}
	for word in s:gsub("%u%w+", " %1"):gsub("[-_]", " "):gmatch("%w+") do
		table.insert(words, word)
	end

	---@return string
	local function snake_case()
		-- return str:gsub("%s", "_")
		return table.concat(words, "_")
	end

	---@return string
	local function SCREAMING_SNAKE_CASE()
		-- return snake_case(str):upper()
		return table.concat(words, "_"):upper()
	end

	---@return string
	local function camelCase()
		-- return str:gsub("%s+(%w)", upper)
		for i, word in ipairs(words) do
			if i > 1 then
				words[i] = word:sub(1, 1):upper() .. word:sub(2)
			end
		end
		return table.concat(words, "")
	end

	---@return string
	local function PascalCase()
		-- return str:gsub("(%w)", upper)
		for i, word in ipairs(words) do
			words[i] = word:sub(1, 1):upper() .. word:sub(2)
		end
		return table.concat(words, "")
	end

	if case == "snake" then
		return snake_case()
	elseif case == "SNAKE" then
		return SCREAMING_SNAKE_CASE()
	elseif case == "camel" then
		return camelCase()
	elseif case == "Pascal" then
		return PascalCase()
	end
end

local last_case = nil

M.make_case = setmetatable({}, {
	__index = function(self, k)
		local str = vim.fn.expand("<cword>")
		vim.fn.setreg("+", do_make_case(str, k))
		vim.api.nvim_feedkeys('viw"+p', "n", false)
		vim.go.operatorfunc = "v:lua.require'willothy.util'.make_case." .. k
		return "g@l"
	end,
	__call = function()
		if not last_case then
			last_case = vim.fn.input("Enter case: ")
		end
		return M.make_case[last_case]()
	end,
})

vim.api.nvim_create_user_command("MakeCase", function(args)
	local case = args["args"]
	local _ = M.make_case[case]
end, { nargs = 1 })

function M.synStack()
	local line = vim.fn.line(".")
	local col = vim.fn.col(".")
	local stack = vim.fn.synstack(line, col)
	for i = 1, #stack do
		local id = stack[i]
		local name = vim.fn.synIDattr(id, "name")
		print(name)
	end
end

return M
