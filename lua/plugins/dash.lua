return {
	{
		"startup-nvim/startup.nvim",
		enabled = false,
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local startup = require("startup")

			local query = require("possession.query")

			local create_button = function(shortcut, text, keymap)
				return { text, keymap, shortcut }
			end

			local workspaces = {
				{
					"Projects",
					"p",
					{
						"~/projects/",
						"~/.config/",
						"~/.config/nvim/",
					},
				},
				{
					"Work",
					"w",
					{
						"~/work/",
					},
				},
			}

			local get_layout = function()
				return query.alpha_workspace_layout(workspaces, create_button, {
					others_name = "Other",
				}) or { "Error" }
			end

			vim.pretty_print(get_layout())

			local utils = require("possession.utils")

			local Section = {
				type = "text",
				oldfiles_directory = false,
				align = "center",
				fold_section = false,
				title = "Title",
				margin = 5,
				content = { "" },
				highlight = "Comment",
				default_color = "",
				oldfiles_amount = 0,
				__call = function(self, opts)
					return vim.tbl_deep_extend("force", self, opts)
				end,
			}

			setmetatable(Section, Section)

			startup.setup({
				header = Section({
					type = "text",
					align = "center",
					content = { "test" },
					highlight = "DashboardHeader",
					title = "Header",
				}),
				buttons = Section({
					type = "mapping",
					align = "center",
					content = {
						{ "  New file", 'call feedkeys("<leader>fn")', "f" },
						{ "  Open last session", 'call feedkeys("<leader>pl")', "l" }, -- session load
						{ "  Open current session", 'call feedkeys("<leader>pc")', "s" },
						{ "  Find file", 'call feedkeys("<leader>ff")', "q" }, -- fuzzy find
						{ "  Projects", 'call feedkeys("<leader>pf")', "w" }, -- open projects folder
						{ "  Recently opened files", "lua require('telescope.builtin').oldfiles()", "r" },
						{ "  Update plugins", "Lazy sync", "u" },
						{ "  Edit neovim config", 'call feedkeys("<leader>nv")', "c" },
					},
					title = "Buttons",
				}),
				-- sessions = Section({
				-- 	type = "mapping",
				-- 	align = "center",
				-- 	content = get_layout(),
				-- }),
				options = {
					mapping_keys = true, -- display mapping (e.g. <leader>ff)

					-- if < 0 fraction of screen width
					-- if > 0 numbers of column
					-- cursor_column = 0.5,

					after = function() -- function that gets executed at the end
					end,
					empty_lines_between_mappings = true, -- add an empty line between mapping/commands
					disable_statuslines = false, -- disable status-, buffer- and tablines
					paddings = { 1, 2 }, -- amount of empty lines before each section (must be equal to amount of sections)
				},
				mappings = {
					execute_command = "<CR>",
					open_file = "o",
					open_file_split = "<c-o>",
					open_section = "<TAB>",
					open_help = "?",
				},
				colors = {
					background = "#1f2227",
					folded_section = "#56b6c2",
				},
				parts = {
					"header",
					"buttons",
					-- "sessions",
				},
			})
		end,
	},
}
