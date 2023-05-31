local M = {}

local namespace = vim.api.nvim_create_namespace("willothy_lsp")

---@param id number LSP Client ID
---@param buf number Buffer number
function M.fetch_hints(id, buf)
	-- local params = vim.lsp.util.make_text_document_params(buf or 0)
	-- local params = vim.lsp.util.make_position_params(0, "utf-8")
	local params = vim.lsp.util.make_range_params(buf or 0, "utf-8")

	local client = vim.lsp.get_client_by_id(id)

	if not client then
		return
	end

	local handler = function(e, res, _cx)
		if res and not e then
			vim.print(res)
			for i, hint in ipairs(res) do
				local opts = {
					id = i,
					virt_text = {
						{
							hint.kind == 1 and (" " .. hint.label[1].value) or (hint.label[1].value .. " "),
							"LspInlayHint",
						},
					},
					virt_text_pos = "inline",
				}
				vim.api.nvim_buf_set_extmark(buf or 0, namespace, hint.position.line, hint.position.character, opts)
			end
		else
			vim.print(e)
		end
	end

	client.request("textDocument/inlayHint", params, handler, buf or 0)
end

-- function M.luahint()
-- 	return vim.lsp.start({
-- 		name = "luahint",
-- 		cmd = { "luahint" },
-- 		root_dir = vim.fn.getcwd(),
-- 	})
-- end
--
-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = "lua",
-- 	callback = function(ev)
-- 		local buf = ev.buf
--
-- 		local client_id = vim.lsp.start_client({
-- 			name = "luahint",
-- 			cmd = { "luahint" },
-- 			root_dir = vim.fn.getcwd(),
-- 		})
-- 		vim.lsp.buf_attach_client(buf, client_id)
--
-- 		-- events when inlay hints should update
-- 		vim.api.nvim_create_autocmd({
-- 			"CursorHold",
-- 			"CursorHoldI",
-- 			"InsertLeave",
-- 			"TextChanged",
-- 		}, {
-- 			callback = function()
-- 				M.get_hints(client_id)
-- 			end,
-- 		})
-- 	end,
-- })
--
-- local ns = vim.api.nvim_create_namespace("lsp_extensions")
-- function M.get_hints(id, buf)
-- 	local params = vim.lsp.util.make_range_params(0, "utf-8")
--
-- 	local client = vim.lsp.get_client_by_id(id)
--
-- 	if not client then
-- 		return
-- 	end
--
-- 	local handler = function(e, res, _cx)
-- 		-- vim.api.nvim_buf_clear_namespace(buf or 0, ns, 0, -1)
-- 		if res and not e then
-- 			for i, hint in ipairs(res) do
-- 				local opts = {
-- 					id = i,
-- 					virt_text = { { hint.kind == 1 and (": " .. hint.label) or (hint.label .. ": "), "LspInlayHint" } },
-- 					virt_text_pos = "inline",
-- 				}
-- 				vim.api.nvim_buf_set_extmark(buf or 0, ns, hint.position.line - 1, hint.position.character - 1, opts)
-- 			end
-- 		end
-- 	end
--
-- 	client.request("textDocument/inlayHint", params, handler, buf or 0)
-- end

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
