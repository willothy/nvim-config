return {
	{
		"folke/noice.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
			"VonHeikemen/lsp-zero.nvim",
		},
		-- enabled = false,
		lazy = true,
		event = "VeryLazy",
		config = function()
			require("noice").setup({
				-- you can enable a preset for easier configuration
				presets = {
					--bottom_search = true, -- use a classic bottom cmdline for search
					--command_palette = true, -- position the cmdline and popupmenu together
					long_message_to_split = true, -- long messages will be sent to a split
					inc_rename = true, -- enables an input dialog for inc-rename.nvim
					-- lsp_doc_border = true, -- add a border to hover docs and signature help
				},
				-- smart_move = {
				-- 	enabled = true,
				-- },
				views = {
					cmdline_popup = {
						position = {
							row = "35%",
							col = "50%",
						},
						border = {
							style = "rounded",
							padding = { 0, 0 },
						},
						filter_options = {},
						win_options = {
							winhighlight = {
								Normal = "Normal",
								FloatBorder = "FloatBorder",
							},
							cursorline = false,
						},
						size = {
							width = "auto",
							height = "auto",
						},
					},
					hover = {
						border = {
							style = "rounded",
							padding = { 0, 0 },
						},
					},
					popupmenu = {
						relative = "editor",
						position = {
							row = "40%",
							col = "50%",
						},
						size = {
							width = 80,
							height = 10,
						},
						border = {
							style = "rounded",
							padding = { 0, 1 },
						},
						win_options = {
							winhighlight = { Normal = "Normal", FloatBorder = "FloatBorder" },
						},
					},
				},
				lsp = {
					--override markdown rendering so that **cmp** and other plugins use **Treesitter**
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
					progress = {
						enabled = false,
					},
					signature = {
						enabled = true,
						auto_open = {
							enabled = true,
							trigger = true,
							luasnip = true,
							throttle = 50,
						},
						view = nil,
						opts = {},
					},
					hover = {
						enabled = true,
					},
				},
				cmdline = {
					view = "cmdline_popup",
					format = {
						search_down = {
							view = "cmdline",
						},
						search_up = {
							view = "cmdline",
						},
					},
				},
				popupmenu = {
					enabled = true,
					backend = "nui",
				},
				messages = {
					-- NOTE: If you enable messages, then the cmdline is enabled automatically.
					-- This is a current Neovim limitation.
					enabled = true, -- enables the Noice messages UI
					view = "notify", -- default view for messages
					view_error = "notify", -- view for errors
					view_warn = "notify", -- view for warnings
					view_history = "messages", -- view for :messages
					view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
				},
				redirect = {
					view = "popup",
					filter = { event = "msg_show" },
				},
			})
			require("telescope").load_extension("noice")
		end,
	},
	{
		"rcarriga/nvim-notify",
		opts = {
			fps = 10,
			render = "compact",
			stages = "static",
			timeout = 4000,
			top_down = false,
			background_color = "none",
		},
	},
}
