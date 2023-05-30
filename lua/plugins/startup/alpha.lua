return {
	{
		"goolord/alpha-nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"jedrzejboczar/possession.nvim",
		},
		lazy = true,
		cmd = "Alpha",
		config = function()
			local alpha = require("alpha")

			local if_nil = vim.F.if_nil

			local default_terminal = {
				type = "terminal",
				command = nil,
				width = 69,
				height = 8,
				opts = {
					redraw = true,
					window_config = {},
				},
			}

			local default_header = {
				type = "text",
				val = {
					"███▄    █ ▓█████  ▒█████   ██▒   █▓ ██▓ ███▄ ▄███▓ ",
					"██ ▀█   █ ▓█   ▀ ▒██▒  ██▒▓██░   █▒▓██▒▓██▒▀█▀ ██▒ ",
					"▓██  ▀█ ██▒▒███   ▒██░  ██▒ ▓██  █▒░▒██▒▓██    ▓██░",
					"▓██▒  ▐▌██▒▒▓█  ▄ ▒██   ██░  ▒██ █░░░██░▒██    ▒██ ",
					"▒██░   ▓██░░▒████▒░ ████▓▒░   ▒▀█░  ░██░▒██▒   ░██▒",
					"░ ▒░   ▒ ▒ ░░ ▒░ ░░ ▒░▒░▒░    ░ ▐░  ░▓  ░ ▒░   ░  ░",
					"░ ░░   ░ ▒░ ░ ░  ░  ░ ▒ ▒░    ░ ░░   ▒ ░░  ░      ░",
					"░   ░ ░    ░   ░ ░ ░ ▒       ░░   ▒ ░░      ░      ",
					"░    ░  ░    ░ ░        ░   ░         ░            ",
					"░                                                  ",
				},
				opts = {
					position = "center",
					hl = "Type",
					-- wrap = "overflow";
				},
			}

			local footer = {
				type = "text",
				val = "",
				opts = {
					position = "center",
					hl = "Number",
				},
			}

			local leader = "SPC"

			--- @param sc string
			--- @param txt string
			--- @param keybind string? optional
			--- @param keybind_opts table? optional
			local function button(sc, txt, keybind, keybind_opts)
				local sc_ = sc:gsub("%s", ""):gsub(leader, "<leader>")

				local opts = {
					position = "center",
					shortcut = sc,
					cursor = 5,
					width = 50,
					align_shortcut = "right",
					hl_shortcut = "Keyword",
				}
				if keybind then
					keybind_opts = if_nil(keybind_opts, { noremap = true, silent = true, nowait = true })
					opts.keymap = { "n", sc_, keybind, keybind_opts }
				end

				local function on_press()
					local key = vim.api.nvim_replace_termcodes(keybind or sc_ .. "<Ignore>", true, false, true)
					vim.api.nvim_feedkeys(key, "t", false)
				end

				return {
					type = "button",
					val = txt,
					on_press = on_press,
					opts = opts,
				}
			end

			local buttons = {
				type = "group",
				val = {
					button("f", "  New file", "<leader>fn"),
					button("l", "  Open last session", "<leader>pl"), -- session load
					button("s", "  Open current session", "<leader>pc"),
					-- button("s", "  Past sessions", "<leader>ls"),
					button("q", "  Find file", "<leader>ff"), -- fuzzy find
					button("w", "  Projects", "<leader>pf"), -- open projects folder
					button("r", "  Recently opened files", "<cmd>lua require('telescope.builtin').oldfiles()<CR>"),
					button("u", "  Update plugins", "<cmd>PackerSync<CR>"),
					button("c", "  Edit neovim config", "<leader>nv"),
				},
				opts = {
					spacing = 1,
				},
			}

			local section = {
				terminal = default_terminal,
				header = default_header,
				buttons = buttons,
				footer = footer,
			}

			local config = {
				section = section,
				layout = {
					{ type = "padding", val = 2 },
					section.header,
					{ type = "padding", val = 2 },
					section.buttons,
					section.footer,
				},
				opts = {
					margin = 5,
				},
			}
			alpha.setup(config)

			-- local theme = {
			-- 	button = button,
			-- 	section = section,
			-- 	config = config,
			-- 	-- theme config
			-- 	leader = leader,
			-- 	-- deprecated
			-- 	opts = config,
			-- }

			vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#5089fa", bg = "none" })
			vim.api.nvim_set_hl(0, "DashboardFooter", { fg = "#5089fa", bg = "none" })
			vim.api.nvim_set_hl(0, "DashboardDesc", { bg = "none" })
			vim.api.nvim_set_hl(0, "DashboardKey", { bg = "none" })
			vim.api.nvim_set_hl(0, "DashboardIcon", { bg = "none" })
			vim.api.nvim_set_hl(0, "DashboardShotCut", { bg = "none" })
			vim.api.nvim_set_hl(0, "EndOfBuf", { bg = "none" })
			vim.api.nvim_set_hl(0, "NonText", { bg = "none" })
		end,
	},
}
