local event = require("nui.utils.autocmd").event
local Menu = require("nui.menu")
local Iter = require("willothy.iter")
local util = require("willothy.util")

local M = {}

local ActionMenu = Menu:extend("ActionMenu")

function ActionMenu:init(items, handler)
	local max_width = vim.api.nvim_win_get_width(0) - 4
	local max_height = vim.api.nvim_win_get_height(0)
	local exec = function(item)
		handler(item)
		self:unmount()
	end

	local popup_opts = {
		relative = "cursor",
		position = {
			row = 1,
			col = 0,
		},
		border = { style = "rounded" },
		zindex = 100,
	}

	local menu_items = {}
	for i, item in ipairs(items) do
		item.index = i
		table.insert(menu_items, Menu.item(item.title, item))
	end

	local menu_opts = {
		min_width = 4,
		max_width = max_width,
		min_height = 1,
		max_height = max_height,
		lines = menu_items,
		keymap = {
			close = { "<Esc>", "<C-c>", "q" },
			submit = { "<CR>" },
		},
		on_close = function()
			exec()
		end,
		on_submit = function(item)
			exec(item)
		end,
	}

	ActionMenu.super.init(self, popup_opts, menu_opts)

	self:on(event.BufLeave, function()
		exec()
	end, { once = true })
end

local get_params = function()
	local ctx = {}
	ctx.diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
	local params = vim.lsp.util.make_range_params()
	params.context = ctx
	return params
end

local code_actions = {
	pending = false,
	buf = nil,
}

function code_actions:exec()
	if self.pending then
		return
	end
	self:request()
end

function code_actions:request()
	self.pending = true
	vim.lsp.buf_request_all(0, "textDocument/codeAction", get_params(), function(results)
		self.pending = false
		self:handler(results)
	end)
end

function code_actions.do_action(item)
	if not item then
		return
	end
	vim.print(item)
	local client = vim.lsp.get_client_by_id(item.client)
	if item.edit then
		local changes = {}
		for uri, edits in pairs(item.edit.changes) do
			table.insert(changes, {
				textDocument = {
					uri = uri,
				},
				edits = edits,
			})
		end
		for _i, change in ipairs(changes) do
			vim.lsp.util.apply_text_document_edit(change, 1, client.offset_encoding)
		end
	elseif item.data then
		client:notify("workspace/executeCommand", item.data)
	end
end

function code_actions:handler(results)
	local items = {}
	for client, result in pairs(results) do
		if result.result then
			for _, item in ipairs(result.result) do
				item.client = client
				table.insert(items, item)
			end
		end
	end
	if #items == 0 then
		return
	end

	ActionMenu(items, self.do_action):mount()
end

M.code_actions = util.bind(code_actions.exec, code_actions)

---@param items { title:string, fn: fun(...) }[]
function M.pick(items, ...)
	if not items then
		return
	end
	local vararg = ...
	ActionMenu(items, function(item)
		if item then
			item.fn(vararg)
		end
	end):mount()
end

function M.quickmenu()
	local menu = {
		{ title = "Code Actions", fn = M.code_actions },
		{
			title = "Test",
			fn = function(...)
				print("test:", ...)
			end,
		},
	}
	M.pick(menu, "bruh")
end

return M
