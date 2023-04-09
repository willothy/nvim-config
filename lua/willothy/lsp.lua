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
