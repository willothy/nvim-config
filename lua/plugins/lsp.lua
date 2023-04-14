local utils = require("willothy.util")
local icons = require("willothy.icons")
local augroup = vim.api.nvim_create_augroup
local setmap = vim.keymap.set
local buf = vim.lsp.buf
local diagnostic = vim.diagnostic
local fn = vim.fn

local function lsp_maps(bufnr)
	local opts = { remap = false, silent = true, buffer = bufnr }

	local function map(m, lhs, rhs, desc)
		setmap(m, lhs, rhs, vim.tbl_deep_extend("keep", opts, { desc = desc }))
	end

	map("n", "gd", buf.definition, "Go to definition")
	map("n", "gD", buf.declaration, "Go to declaration")
	map("n", "gT", buf.type_definition, "Go to type definition")
	map("n", "gi", buf.implementation, "Go to implementation")
	map("n", "K", function()
		require("rust-tools").hover_actions.hover_actions()
	end, "Hover docs")
	map("n", "<leader>ws", buf.workspace_symbol, "Find workspace symbol")
	map("n", "<leader>fd", diagnostic.open_float, "Diagnostic float")
	map("n", "[d", diagnostic.goto_next, "Next diagnostic")
	map("n", "]d", diagnostic.goto_prev, "Previous diagnostic")
	-- map("n", "<leader>ca", buf.code_action, opts)
	-- map("n", "<leader>ca", require("willothy.actions").code_actions, "Code actions")
	map("n", "<leader>ca", require("rust-tools").code_action_group.code_action_group, "Code actions")
	-- map("n", "<leader>vrr", buf.references, opts)
	map("n", "<leader>hs", buf.signature_help, "Signature help")

	-- Glance
	local glance = require("glance").actions.open
	map("n", "<leader>rr", utils.bind(glance, "references"), "Glance references")
	map("n", "<leader>vd", utils.bind(glance, "definitions"), "Glance definitions")
	map("n", "<leader>vd", utils.bind(glance, "type_definitions"), "Glance type definitions")
	map("n", "<leader>vi", utils.bind(glance, "implementations"), "Glance implementations")

	-- IncRename
	local ts_utils = require("nvim-treesitter.ts_utils")
	local increname = function()
		local cword = fn.expand("<cword>")
		local node = ts_utils.get_node_at_cursor()

		local type = node:type()
		if type ~= nil and string.match(type, "identifier") ~= nil then
			require("willothy.lsp").if_defined_in_workspace(function()
				vim.api.nvim_feedkeys(":IncRename " .. cword, "n", false)
			end)
		else
			return
		end
	end
	setmap("n", "<leader>rn", increname, { expr = true, desc = "Rename" })
	setmap("n", "<F2>", increname, { expr = true, desc = "Rename" })
end

local inlayhints
local function setup_inlayhints()
	inlayhints = require("lsp-inlayhints")
	inlayhints.setup({
		inlay_hints = {
			parameter_hints = {
				show = true,
				separator = "",
				remove_colon_start = true,
				remove_colon_end = true,
			},
			type_hints = {
				show = true,
				separator = "",
				remove_colon_start = true,
				remove_colon_end = true,
			},
			label_formatter = function(labels, _kind, _opts, _client_name)
				return table.concat(labels or {}, "")
			end,
			virt_text_formatter = function(label, hint, _opts, client_name)
				if client_name == "lua_ls" then
					if hint.kind == 2 then
						hint.paddingLeft = false
					else
						hint.paddingRight = false
					end
				end

				local virt_text = {}
				virt_text[#virt_text + 1] = hint.paddingLeft and { " ", "Normal" } or nil
				virt_text[#virt_text + 1] = { label, "NormalNC" }
				virt_text[#virt_text + 1] = hint.paddingRight and { " ", "Normal" } or nil

				return virt_text
			end,
			highlight = "LspInlayHint",
		},
		enabled_at_startup = true,
	})
end

local format
local format_group = augroup("lsp_format_group", {})
local function setup_format()
	format = require("lsp-format")
	format.setup()
end

local function lsp_attach(client, bufnr)
	lsp_maps(bufnr)
	if not format then
		setup_format()
	end
	if not inlayhints then
		setup_inlayhints()
	end

	format.on_attach(client)
	inlayhints.on_attach(client, bufnr, false)

	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_clear_autocmds({ group = format_group, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = format_group,
			buffer = bufnr,
			callback = function()
				-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
				buf.format({ bufnr = bufnr })
			end,
		})
	end
end

local lsp_settings = {
	["bash-language-server"] = {
		bashIde = {
			includeAllWorkspaceSymbols = true,
		},
	},
	clangd = {},
	["lua_ls"] = {
		Lua = {
			format = {
				enable = false,
			},
			diagnostics = {
				enable = false,
				globals = { "vim" },
			},
			workspace = {
				checkThirdParty = false,
			},
			completion = {
				enable = true,
				autoRequire = true,
				callSnippet = "Replace",
				-- workspaceDelay = 1000,
			},
			-- hint = {
			-- 	enable = false,
			-- 	arrayIndex = "Enable",
			-- 	await = true,
			-- 	paramName = "All",
			-- 	paramType = true,
			-- 	semicolon = "SameLine",
			-- 	setType = true,
			-- },
		},
	},
}

local function setup_null()
	local null_ls = require("null-ls")
	local builtins = null_ls.builtins

	null_ls.setup({
		sources = {
			builtins.formatting.stylua,
			builtins.formatting.prettier,
			-- null.fmt.rustfmt,
			-- null.cmp.spell,
			-- null.cmp.luasnip,
			-- null.diag.cspell,
			-- null.diag.luacheck,
			builtins.diagnostics.selene,
			builtins.diagnostics.todo_comments,
			-- null.diag.trailspace,
			-- null.ca.cspell,
			builtins.code_actions.gitrebase,
			-- null.ca.gitsigns,
			-- null.ca.refactoring,
		},
		on_attach = lsp_attach,
	})
end

local function setup_ufo()
	local handler = function(virtText, lnum, endLnum, width, truncate)
		local newVirtText = {}
		local suffix = ("  %d "):format(endLnum - lnum)
		local sufWidth = fn.strdisplaywidth(suffix)
		local targetWidth = width - sufWidth
		local curWidth = 0
		for _, chunk in ipairs(virtText) do
			local chunkText = chunk[1]
			local chunkWidth = fn.strdisplaywidth(chunkText)
			if targetWidth > curWidth + chunkWidth then
				table.insert(newVirtText, chunk)
			else
				chunkText = truncate(chunkText, targetWidth - curWidth)
				local hlGroup = chunk[2]
				table.insert(newVirtText, { chunkText, hlGroup })
				chunkWidth = fn.strdisplaywidth(chunkText)
				-- str width returned from truncate() may less than 2nd argument, need padding
				if curWidth + chunkWidth < targetWidth then
					suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
				end
				break
			end
			curWidth = curWidth + chunkWidth
		end
		table.insert(newVirtText, { suffix, "MoreMsg" })
		return newVirtText
	end

	-- global handler
	-- `handler` is the 2nd parameter of `setFoldVirtTextHandler`,
	-- check out `./lua/ufo.lua` and search `setFoldVirtTextHandler` for detail.
	require("ufo").setup({
		fold_virt_text_handler = handler,
	})
end

local function setup_rust()
	require("rust-tools").setup({
		tools = {
			inlay_hints = {
				auto = false,
			},
			hover_actions = {},
		},
		server = {
			-- standalone = false,
			on_attach = lsp_attach,
			settings = {
				assist = {
					importGranularity = "module",
					importPrefix = "by_self",
				},
				cargo = {
					loadOutDirsFromCheck = true,
				},
				procMacro = {
					enable = true,
					enabled = true,
				},
				procMacros = {
					enable = true,
					enabled = true,
				},
				imports = {
					prefix = "self",
				},
				inlayHints = {
					render_colons = true,
					type_hints = true,
					parameter_hints = true,
					chaining_hints = true,
					hide_closure_initialization_hints = false,
					adjustment_hints = {
						enable = "always",
					},
					discriminant_hints = {
						enable = "always",
					},
					lifetimeElisionHints = {
						enable = "always",
						useParemeterNames = true,
					},
					closureReturnTypeHints = {
						enable = "always",
					},
					discriminantHints = {
						enable = "fieldless",
					},
					bindingModeHints = {
						enable = true,
					},
				},
				lens = {
					run = true,
					enable = true,
					implementations = {
						enable = true,
					},
					method_refs = {
						enable = true,
					},
					references = {
						adt = {
							enable = true,
						},
						enumVariant = {
							enable = true,
						},
						method = {
							enable = true,
						},
						trait = {
							enable = true,
						},
					},
				},
				hover = {
					actions = {
						references = {
							enable = true,
						},
					},
				},
			},
		},
	})
end

local function lsp_setup()
	-- require("neodev").setup({})

	vim.lsp.set_log_level("off")

	require("mason").setup({})
	local mason_lspconfig = require("mason-lspconfig")
	mason_lspconfig.setup({})
	require("mason-null-ls").setup({
		automatic_setup = true,
	})
	local lspconfig = require("lspconfig")
	local lspcfg_cfg = require("lspconfig.configs")
	local cmp_lsp = require("cmp_nvim_lsp")

	local capabilities = vim.lsp.protocol.make_client_capabilities()

	-- snippets
	capabilities.textDocument.completion.completionItem.snippetSupport = true

	-- send actions with hover request
	capabilities.experimental = {
		hoverActions = true,
		hoverRange = true,
		serverStatusNotification = true,
		snippetTextEdit = true,
		codeActionGroup = true,
		ssr = true,
	}

	-- enable auto-import
	capabilities.textDocument.completion.completionItem.resolveSupport = {
		properties = { "documentation", "detail", "additionalTextEdits" },
	}

	capabilities.offsetEncoding = "utf-8"

	cmp_lsp.default_capabilities(capabilities)

	-- local servers = get_servers()
	mason_lspconfig.setup_handlers({
		function(server_name)
			lspconfig[server_name].setup({
				capabilities = capabilities,
				on_attach = lsp_attach,
				settings = lsp_settings[server_name] or {},
			})
		end,
	})
	setup_rust()

	setup_null()
	setup_ufo()
	setup_format()
	setup_inlayhints()

	local sign = function(opts)
		vim.fn.sign_define(opts.name, {
			texthl = opts.hl or opts.name,
			text = opts.text,
		})
	end

	sign({ name = "DiagnosticSignError", text = icons.diagnostics.errors })
	sign({ name = "DiagnosticSignWarn", text = icons.diagnostics.warnings })
	sign({ name = "DiagnosticSignHint", text = icons.diagnostics.hints })
	sign({ name = "DiagnosticSignInfo", text = icons.diagnostics.info })
	sign({ name = "LightBulbSign", text = icons.lsp.action_hint, hl = "DiagnosticSignWarn" })

	diagnostic.config({
		virtual_text = {
			prefix = "",
			format = function(diag)
				local severity = "Info"
				if diag.severity == 1 then
					severity = "Error"
				elseif diag.severity == 2 then
					severity = "Warn"
				elseif diag.severity == 3 then
					severity = "Hint"
				end
				return string.format("%s %s", icons.diagnostics[severity], diag.message)
			end,
		},
		signs = true,
		update_in_insert = true,
		underline = false,
		severity_sort = true,
		float = {
			source = "always",
			border = "rounded",
			focusable = false,
		},
	})
end

local aerial_opt = {
	dense = true,
	depth = 5,
}

local function aerial_cfg()
	setmap("n", "<leader>o", function()
		require("aerial").toggle()
	end, {
		desc = "Toggle aerial window",
	})
end

local fidget = {
	text = {
		spinner = "pipe", --"dots",
		done = "✓",
		commenced = "+",
		completed = "✓",
	},
	fmt = {
		stack_upwards = false,
	},
	align = {
		bottom = false,
		right = true,
	},
	window = {
		blend = 0,
		relative = "editor",
	},
}

return {
	{
		"stevearc/aerial.nvim",
		opts = aerial_opt,
		init = aerial_cfg,
		lazy = true,
		cmd = "AerialToggle",
	},
	{
		"folke/neodev.nvim",
		lazy = true,
		ft = "lua",
		config = true,
	},
	{
		"j-hui/fidget.nvim",
		opts = fidget,
		lazy = true,
		config = true,
		event = "LspAttach",
	},
	{
		"smjonas/inc-rename.nvim",
		config = true,
		lazy = false,
	},
	{
		"lvimuser/lsp-inlayhints.nvim",
		branch = "anticonceal",
		lazy = true,
		event = "LSPAttach",
	},
	{
		"lukas-reineke/lsp-format.nvim",
		lazy = true,
		event = "LSPAttach",
	},
	{
		"simrat39/rust-tools.nvim",
		lazy = true,
	},
	{
		"williamboman/mason.nvim",
		lazy = true,
		event = "VeryLazy",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"jay-babu/mason-null-ls.nvim",
			"folke/neodev.nvim",
		},
	},
	{
		"neovim/nvim-lspconfig",
		lazy = true,
		event = "VeryLazy",
		config = lsp_setup,
	},
	{
		"dnlhc/glance.nvim",
		lazy = true,
		event = "LSPAttach",
		config = function()
			local glance = require("glance")
			local actions = glance.actions

			local cfg = {
				theme = {
					enable = true,
					mode = "auto",
				},
				border = {
					enable = true,
				},
				preview_win_opts = {
					wrap = false,
				},
				mappings = {
					list = {
						["<Tab>"] = actions.enter_win("preview"),
					},
					preview = {
						["<Tab>"] = actions.enter_win("list"),
					},
				},
				-- detached = true,
				hooks = {
					before_open = function(results, open, _jump, _method)
						open(results)
					end,
				},
				winbar = {
					enable = true,
				},
			}

			glance.setup(cfg)
		end,
	},
	{
		"utilyre/barbecue.nvim",
		dependencies = {
			"SmiteshP/nvim-navic",
		},
		config = function()
			require("barbecue").setup({
				attach_navic = true,
				theme = "minimus",
				show_modified = true,
				exclude_filetypes = {
					"gitcommit",
					"toggleterm",
					"Glance",
					"mason",
					"alpha",
				},
				modified = function()
					return true
				end,
				symbols = {
					separator = icons.separators.angle_quote.right,
					modified = icons.kinds.Package,
				},
				kinds = require("willothy.icons").kinds,
			})
		end,
	},
	{
		"kevinhwang91/nvim-ufo",
		name = "ufo",
		dependencies = {
			"kevinhwang91/promise-async",
		},
		init = function()
			-- vim.o.foldcolumn = "1"
			-- vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
			-- vim.o.foldlevel = 99
			-- vim.o.foldenable = true
			-- vim.o.foldlevelstart = 99
			-- vim.o.foldopen = "block,mark,percent,quickfix,search,tag,undo"
		end,
		lazy = true,
	},
	{
		"weilbith/nvim-code-action-menu",
		lazy = true,
		cmd = "CodeActionMenu",
	},
	{
		"jose-elias-alvarez/null-ls.nvim",
		lazy = true,
	},
	{
		"ThePrimeagen/refactoring.nvim",
		lazy = true,
		enabled = false,
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
	},
	{
		"kosayoda/nvim-lightbulb",
		config = function()
			local l = require("nvim-lightbulb")
			l.setup({
				-- ignore = { "null-ls" },
				autocmd = {
					enabled = false,
				},
				virtual_text = {
					enabled = false,
					text = icons.lsp.action_hint,
				},
				status_text = {
					text = icons.lsp.action_hint,
				},
			})
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorMoved" }, {
				pattern = "*",
				callback = function()
					require("nvim-lightbulb").update_lightbulb()
				end,
			})
		end,
		lazy = true,
		event = "LspAttach",
	},
}
