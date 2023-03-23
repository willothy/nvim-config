local utils = require("willothy.util")

local function lsp_zero()
	local lsp = require("lsp-zero")
	vim.lsp.set_log_level("off")
	lsp.preset({
		name = "recommended",
		set_lsp_keymaps = false,
		manage_nvim_cmp = false,
		suggest_lsp_servers = true,
	})

	lsp.on_attach(function(client, buffer)
		local opts = { buffer = buffer, remap = false }

		local format = require("lsp-format")
		format.setup()
		format.on_attach(client)

		local inlayhints = require("lsp-inlayhints")
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
					virt_text[#virt_text + 1] = { label, opts.highlight }
					virt_text[#virt_text + 1] = hint.paddingRight and { " ", "Normal" } or nil

					return virt_text
				end,
				highlight = "LspInlayHint",
			},
			enabled_at_startup = true,
		})
		inlayhints.on_attach(client, buffer, false)

		opts.desc = "Go to definition"
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		opts.desc = "Go to declaration"
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		opts.desc = "Go to type definition"
		vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, opts)
		opts.desc = "Go to implementation"
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		opts.desc = "Hover"
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		opts.desc = "Find workspace symbol"
		vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts)
		opts.desc = "Open diagnostic in float"
		vim.keymap.set("n", "<leader>fd", vim.diagnostic.open_float, opts)
		opts.desc = "Go to next diagnostic"
		vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
		opts.desc = "Go to previous diagnostic"
		vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
		opts.desc = "Code actions"
		-- vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "<leader>ca", function()
			vim.api.nvim_exec("CodeActionMenu", true)
		end, opts)
		-- vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
		opts.desc = "Signature help"
		vim.keymap.set("n", "<leader>hs", vim.lsp.buf.signature_help, opts)

		local glance = require("glance").actions
		opts.desc = "Glance references"
		vim.keymap.set("n", "<leader>rr", utils.bind(glance.open, "references"), opts)
		opts.desc = "Glance definitions"
		vim.keymap.set("n", "<leader>vd", utils.bind(glance.open, "definitions"), opts)
		opts.desc = "Glance type definitions"
		vim.keymap.set("n", "<leader>vd", utils.bind(glance.open, "type_definitions"), opts)
		opts.desc = "Glance implementations"
		vim.keymap.set("n", "<leader>vi", utils.bind(glance.open, "implementations"), opts)
	end)

	vim.api.nvim_exec(
		[[
nmenu PopUp.Show\ References   :lua vim.lsp.buf.references()
nmenu PopUp.Goto\ Definition   :lua vim.lsp.buf.definition()
nmenu PopUp.Goto\ Declaration  :lua vim.lsp.buf.declaration()
nmenu PopUp.Code\ Actions      :lua vim.lsp.buf.code_action()
nmenu PopUp.Rename              :lua vim.lsp.buf.rename()<CR>")
nmenu PopUp.Signature\ Help    :lua vim.lsp.buf.signature_help()
]],
		true
	)

	lsp.configure("bash-language-server", {
		settings = {
			bashIde = {
				includeAllWorkspaceSymbols = true,
			},
		},
	})

	lsp.configure("lua_ls", {
		settings = {
			Lua = {
				format = {
					enable = false,
				},
				["completion.enable"] = true,
				diagnostics = {
					enable = false,
					globals = { "vim" },
					-- ["unused-vararg"]
					-- disable = { "unused-local" },
				},
			},
		},
	})

	local null_ls = require("null-ls")

	local null_opts = lsp.build_options("null-ls", {
		on_attach = function(client)
			if client.server_capabilities.documentFormattingProvider then
				vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.format()")
			end
		end,
	})

	local null = {
		fmt = null_ls.builtins.formatting,
		cmp = null_ls.builtins.completion,
		diag = null_ls.builtins.diagnostics,
		ca = null_ls.builtins.code_actions,
	}

	null_ls.setup({
		on_attach = null_opts.on_attach,
		sources = {
			null.fmt.stylua,
			null.fmt.prettier,
			-- null.fmt.rustfmt,
			-- null.cmp.spell,
			-- null.cmp.luasnip,
			-- null.diag.cspell,
			-- null.diag.luacheck,
			null.diag.selene,
			null.diag.todo_comments,
			-- null.diag.trailspace,
			-- null.ca.cspell,
			null.ca.gitrebase,
			null.ca.gitsigns,
			null.ca.refactoring,
		},
	})

	lsp.configure("rust_analyzer", {
		settings = {
			["rust-analyzer"] = {
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
	lsp.setup()

	local handler = function(virtText, lnum, endLnum, width, truncate)
		local newVirtText = {}
		local suffix = ("  %d "):format(endLnum - lnum)
		local sufWidth = vim.fn.strdisplaywidth(suffix)
		local targetWidth = width - sufWidth
		local curWidth = 0
		for _, chunk in ipairs(virtText) do
			local chunkText = chunk[1]
			local chunkWidth = vim.fn.strdisplaywidth(chunkText)
			if targetWidth > curWidth + chunkWidth then
				table.insert(newVirtText, chunk)
			else
				chunkText = truncate(chunkText, targetWidth - curWidth)
				local hlGroup = chunk[2]
				table.insert(newVirtText, { chunkText, hlGroup })
				chunkWidth = vim.fn.strdisplaywidth(chunkText)
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

	vim.diagnostic.config({
		virtual_text = true,
		signs = true,
		update_in_insert = true,
		underline = false,
		severity_sort = true,
		float = {
			show_header = false,
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
	vim.keymap.set("n", "<leader>o", function()
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

local function inc_rename()
	local increname = function()
		return ":IncRename " .. vim.fn.expand("<cword>")
	end
	vim.keymap.set("n", "<leader>rn", increname, { expr = true, desc = "Rename" })
	vim.keymap.set("n", "<F2>", increname, { expr = true, desc = "Rename" })
end

local glance = {
	theme = {
		enable = false,
		mode = "darken",
	},
	border = {
		enable = false,
		-- unicode line characters
		-- top_left = "┌",
		-- top_right = "┐",
		-- bottom_left = "└",
		-- bottom_right = "┘",
		-- vertical = "│",
		-- horizontal = "─",
		top_char = "─",
		bottom_char = "─",
	},
	detached = true,
	winbar = {
		enable = true,
	},
}

local lightbulb = {
	autocmd = { enabled = true },
}

return {
	{
		"VonHeikemen/lsp-zero.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",

			-- Config dependencies
			"lvimuser/lsp-inlayhints.nvim",
			"lukas-reineke/lsp-format.nvim",
			"SmiteshP/nvim-navic",
			"folke/neodev.nvim",
		},
		config = lsp_zero,
		lazy = true,
		event = "VeryLazy",
	},
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
		event = "LspAttach",
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
		init = inc_rename,
		config = true,
		lazy = true,
		cmd = "IncRename",
	},
	{
		"lvimuser/lsp-inlayhints.nvim",
		branch = "anticonceal",
		lazy = true,
		event = "LSPAttach",
	},
	{
		"williamboman/mason.nvim",
		lazy = true,
		event = "VeryLazy",
	},
	{
		"dnlhc/glance.nvim",
		lazy = true,
		event = "LSPAttach",
		opts = glance,
	},
	{
		"kosayoda/nvim-lightbulb",
		lazy = true,
		event = "LSPAttach",
		opts = lightbulb,
		dependencies = {
			"antoinemadec/FixCursorHold.nvim",
		},
	},
	{
		"utilyre/barbecue.nvim",
		dependencies = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons", -- optional dependency
		},
		lazy = true,
		event = "BufEnter",
		config = function()
			-- local p = require('minimus.palette').hex
			require("barbecue").setup({
				attach_navic = true,
				theme = "minimus",
				exclude_filetypes = {
					"gitcommit",
					"toggleterm",
					"Glance",
					"mason",
					"alpha",
				},
			})
		end,
	},
	{
		"kevinhwang91/nvim-ufo",
		name = "ufo",
		dependencies = {
			"kevinhwang91/promise-async",
			"VonHeikemen/lsp-zero.nvim",
		},
		init = function()
			vim.o.foldcolumn = "1"
			vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
			vim.o.foldlevel = 99
			vim.o.foldenable = true
			vim.o.foldlevelstart = 99
			vim.o.foldopen = "block,mark,percent,quickfix,search,tag,undo"
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
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
	},
}
