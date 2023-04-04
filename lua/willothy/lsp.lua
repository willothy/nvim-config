local event = require("nui.utils.autocmd").event
local Menu = require("nui.menu")
local Iter = require("willothy.iter")

local M = {}

-- a lot of this is from https://github.com/simrat39/rust-tools.nvim

-- callback args changed in Neovim 0.5.1/0.6. See:
-- https://github.com/neovim/neovim/pull/15504
function M.mk_handler(fn)
	return function(...)
		local config_or_client_id = select(4, ...)
		local is_new = type(config_or_client_id) ~= "number"
		if is_new then
			fn(...)
		else
			local err = select(1, ...)
			local method = select(2, ...)
			local result = select(3, ...)
			local client_id = select(4, ...)
			local bufnr = select(5, ...)
			local config = select(6, ...)
			fn(err, result, { method = method, client_id = client_id, bufnr = bufnr }, config)
		end
	end
end

function M.request(bufnr, method, params, handler)
	return vim.lsp.buf_request(bufnr, method, params, M.mk_handler(handler))
end

function M.get_active_client(bufnr, required)
	local clients = vim.lsp.get_active_clients({ bufnr = bufnr or 0 })
	local active = nil
	for _, client in pairs(clients) do
		if client.supports_method(required) then
			active = client
			break
		end
	end

	return active
end

function M.if_defined_in_workspace(f)
	local position_params = vim.lsp.util.make_position_params()
	vim.lsp.buf_request(0, "textDocument/definition", position_params, function(_, result)
		if not result then
			return
		end
		local res = result[1]
		if res.targetUri:find(vim.fn.getcwd()) then
			f()
		end
	end)
end

local ActionMenu = Menu:extend("ActionMenu")

function ActionMenu:init(items)
	local max_width = vim.api.nvim_win_get_width(0) - 4
	local max_height = vim.api.nvim_win_get_height(0)
	local exec = function(item)
		if item then
			if type(item) == "table" and item.edit then
				local client = vim.lsp.get_client_by_id(item.client)
				local changes = {}
				for uri, edits in pairs(item.edit.changes) do
					table.insert(changes, {
						textDocument = {
							uri = uri,
						},
						edits = edits,
					})
				end
				for _, change in ipairs(changes) do
					vim.lsp.util.apply_text_document_edit(change, 1, client.offset_encoding)
				end
			elseif type(item) == "string" then
				vim.api.nvim_exec(item)
			elseif type(item) == "function" then
				item()
			end
		end
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

	local menu_items = Iter:new(items):enumerate():map(function(v)
		v[2].index = v[1]
		return Menu.item(v[2].title, v[2])
	end)

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

function M.code_actions()
	local context = {}
	context.diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
	local params = vim.lsp.util.make_range_params()
	params.context = context
	vim.lsp.buf_request_all(0, "textDocument/codeAction", params, function(results)
		local items = Iter:new(results)
			:enumerate()
			:filter(function(res)
				return type(res) == "table" and type(res[2]) == "table" and res[2].result ~= nil
			end)
			:map(function(res)
				local client = res[1]
				return Iter:new(res[2].result)
					:map(function(v)
						v.client = client
						return v
					end)
					:collect()
			end)
			:collect()[1]
		vim.print(items)
		ActionMenu(items):mount()
	end)
end

function M.parent_module()
	local function get_params()
		return vim.lsp.util.make_position_params(0, nil)
	end
	local function handler(_, result, ctx)
		if result == nil or vim.tbl_isempty(result) then
			vim.api.nvim_out_write("Can't find parent module\n")
			return
		end

		local location = result

		if vim.tbl_islist(result) then
			location = result[1]
		end

		local client = vim.lsp.get_client_by_id(ctx.client_id)
		vim.lsp.util.jump_to_location(location, client.offset_encoding)
	end

	M.request(0, "experimental/parentModule", get_params(), handler)
end

function M.open_cargo_toml()
	local function get_params()
		return {
			textDocument = vim.lsp.util.make_text_document_params(0),
		}
	end
	local function handler(_, result, ctx)
		if result == nil then
			return
		end

		local client = vim.lsp.get_client_by_id(ctx.client_id)
		vim.lsp.util.jump_to_location(result, client.offset_encoding)
	end
	M.request(0, "experimental/openCargoToml", get_params(), handler)
end

function M.open_external_docs()
	M.request(0, "experimental/externalDocs", vim.lsp.util.make_position_params(), function(_, url)
		if url then
			vim.fn["netrw#BrowseX"](url, 0)
		end
	end)
end

return M
