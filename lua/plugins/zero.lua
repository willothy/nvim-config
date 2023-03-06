local utils = require("willothy.util")

local function lspzero()
	local lsp = require('lsp-zero')
	lsp.preset({
		name = 'recommended',
		set_lsp_keymaps = false,
		manage_nvim_cmp = false,
		suggest_lsp_servers = true,
	})

	lsp.on_attach(function(client, bufnr)
		local opts = { buffer = bufnr, remap = false }

		local format = require('lsp-format')
		format.setup()
		format.on_attach(client)

		local inlayhints = require('lsp-inlayhints')
		inlayhints.setup({
			inlay_hints = {
				parameter_hints = {
					show = true,
					separator = '',
					remove_colon_start = true,
					remove_colon_end = true,
				},
				type_hints = {
					show = true,
					separator = '',
					remove_colon_start = true,
					remove_colon_end = true,
				},
				label_formatter = function(labels, kind, opts, client_name)
					return table.concat(labels or {}, "")
				end,
				virt_text_formatter = function(label, hint, opts, client_name)
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
				--priority = 0,
			},
			enabled_at_startup = true,
		})
		inlayhints.on_attach(client, bufnr)

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
		vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
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

	vim.api.nvim_exec([[
nmenu PopUp.Show\\ References   :lua vim.lsp.buf.references()
nmenu PopUp.Goto\\ Definition   :lua vim.lsp.buf.definition()
nmenu PopUp.Goto\\ Declaration  :lua vim.lsp.buf.declaration()
nmenu PopUp.Code\\ Actions      :lua vim.lsp.buf.code_action()
nmenu PopUp.Rename              :lua vim.lsp.buf.rename()<CR>")
nmenu PopUp.Signature\\ Help    :lua vim.lsp.buf.signature_help()
]], true)

	lsp.configure('bash-language-server', {
		settings = {
			bashIde = {
				includeAllWorkspaceSymbols = true
			}
		}
	})

	lsp.configure('rust_analyzer', {
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
					enabled = true
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
						useParemeterNames = true
					},
					closureReturnTypeHints = {
						enable = "always"
					},
					discriminantHints = {
						enable = "fieldless"
					},
					bindingModeHints = {
						enable = true
					}
				},
				lens = {
					run = true,
					enable = true,
					implementations = {
						enable = true
					},
					method_refs = {
						enable = true
					},
					references = {
						adt = {
							enable = true
						},
						enumVariant = {
							enable = true
						},
						method = {
							enable = true
						},
						trait = {
							enable = true
						},
					}
				},
				hover = {
					actions = {
						references = {
							enable = true
						}
					}
				}
			},
		},
	})
	lsp.setup()

	local handler = function(virtText, lnum, endLnum, width, truncate)
		local newVirtText = {}
		local suffix = ('  %d '):format(endLnum - lnum)
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
					suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
				end
				break
			end
			curWidth = curWidth + chunkWidth
		end
		table.insert(newVirtText, { suffix, 'MoreMsg' })
		return newVirtText
	end

	-- global handler
	-- `handler` is the 2nd parameter of `setFoldVirtTextHandler`,
	-- check out `./lua/ufo.lua` and search `setFoldVirtTextHandler` for detail.
	require('ufo').setup({
		fold_virt_text_handler = handler,
	})

	vim.diagnostic.config({
		virtual_text = true,
		signs = true,
		update_in_insert = true,
		underline = true,
		severity_sort = true,
		float = true,
	})
end

local aerial_opt = {
	dense = true,
	depth = 5
}

local function aerial_cfg()
	vim.keymap.set("n", "<leader>o", function()
		require('aerial').toggle()
	end, {
		desc = "Toggle aerial window"
	})
end

local fidget = {
	text = {
		spinner = "dots",
		done = "✓",
		commenced = "",
		completed = "✓",
	},
	window = {
		blend = 0
	}
}
local function inc_rename()
	local increname = function()
		return ":IncRename " .. vim.fn.expand("<cword>")
	end
	vim.keymap.set("n", "<leader>rn", increname, { expr = true, desc = "Rename" })
	vim.keymap.set("n", "<F2>", increname, { expr = true, desc = "Rename" })
end

local neodev = {
	plugins = { "willothy" }
}

local glance = {
	theme = {
		enable = false,
		mode = 'darken'
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
		bottom_char = "─"
	},
	detached = true,
	winbar = {
		enable = true
	}
}

local lightbulb = {
	autocmd = { enabled = true }
}

return {
	{
		'VonHeikemen/lsp-zero.nvim',
		dependencies = {
			'neovim/nvim-lspconfig',
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',

			-- Config dependencies
			'lvimuser/lsp-inlayhints.nvim',
			'lukas-reineke/lsp-format.nvim',
			'SmiteshP/nvim-navic',
			'folke/neodev.nvim',
		},
		init = lspzero,
		lazy = true,
		config = true,
		event = 'VeryLazy',
	},
	{
		'stevearc/aerial.nvim',
		opts = aerial_opt,
		init = aerial_cfg,
		event = 'LSPAttach',
	},
	{
		'folke/neodev.nvim',
		lazy = true,
		opts = neodev,
		event = 'BufEnter',
	},
	{
		'j-hui/fidget.nvim',
		opts = fidget,
		lazy = true,
		event = 'VeryLazy',
		config = true,
	},
	{
		'smjonas/inc-rename.nvim',
		init = inc_rename,
		config = true,
		event = 'LSPAttach',
	},
	{
		'lvimuser/lsp-inlayhints.nvim',
		branch = "anticonceal",
		lazy = true,
		event = 'LSPAttach',
	},
	{
		'williamboman/mason.nvim',
		lazy = true,
		event = 'VeryLazy',
	},
	{
		'dnlhc/glance.nvim',
		lazy = true,
		event = 'LSPAttach',
		opts = glance,
	},
	{
		'kosayoda/nvim-lightbulb',
		lazy = true,
		event = 'LSPAttach',
		opts = lightbulb,
		dependencies = {
			'antoinemadec/FixCursorHold.nvim'
		}
	},
	{
		'utilyre/barbecue.nvim',
		dependencies = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons", -- optional dependency
			dir = '~/projects/lua/minimus/'
		},
		lazy = true,
		event = 'BufEnter',
		config = function()
			local p = require('minimus.palette').hex
			require("barbecue").setup({
				attach_navic = true,
				theme = 'minimus',
				exclude_filetypes = {
					"gitcommit",
					"toggleterm",
					"Glance",
					"mason",
					"alpha"
				}
			})
		end
	},
	{
		'kevinhwang91/nvim-ufo',
		name = 'ufo',
		dependencies = {
			'kevinhwang91/promise-async',
			'VonHeikemen/lsp-zero.nvim'
		},
		init = function()
			vim.o.foldcolumn = '1'
			vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
			vim.o.foldlevel = 99
			vim.o.foldenable = true
			vim.o.foldlevelstart = 99
		end
	}, {
	'weilbith/nvim-code-action-menu',
	cmd = 'CodeActionMenu',
}
}
