return {
	{
		"startup-nvim/startup.nvim",
		enabled = true,
		init = function()
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "startup",
				callback = function(evt)
					require("sidebar-nvim").close()
					vim.api.nvim_create_autocmd("BufWinLeave", {
						once = true,
						callback = function(evt)
							require("sidebar-nvim").open()
						end,
					})
				end,
			})
		end,
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local startup = require("startup")

			local create_button = function(shortcut, text, keymap)
				return { text, keymap, shortcut }
			end

			local workspaces = {
				Projects = { "~/projects/rust" },
				Dotfiles = {
					"~/.config",
					-- "~/.config/nvim",
				},
			}

			local scandir = require("plenary.scandir")
			local Path = require("plenary.path")
			local Iter = require("willothy.iter")

			local cwd = vim.fn.getcwd()
			local project_layout = function()
				local layout = {}
				for name, dirs in pairs(workspaces) do
					for _, dir in ipairs(dirs) do
						dir = vim.fn.fnamemodify(dir, ":p")
						local projects = scandir.scan_dir(dir, {
							hidden = true,
							only_dirs = true,
							depth = 1,
							respect_gitignore = true,
							silent = true,
							title = name,
						})

						projects = vim.tbl_filter(function(v)
							v = string.gsub(v, "//", "/")
							return v ~= cwd and Path:new(v):joinpath(".git"):exists()
						end, projects)

						for _, p in ipairs(projects) do
							p = string.gsub(p, "//", "/")
							table.insert(layout, #layout + 1, p)
						end
					end
				end
				table.sort(layout, function(a, b)
					-- sort by last accessed
					local a_stat = vim.loop.fs_stat(a)
					local b_stat = vim.loop.fs_stat(b)
					local a_mod = a_stat.mtime.sec
					local b_mod = b_stat.mtime.sec
					local a_accessed = a_stat.atime.sec
					local b_accessed = b_stat.atime.sec
					return a_accessed > b_accessed or a_mod > b_mod
				end)
				local keys = {
					"w",
					"a",
					"s",
					"d",
					"f",
				}
				local i = 0
				return vim.tbl_map(function(v)
					local text = vim.fn.fnamemodify(v, ":~:.")
					i = i + 1
					return { text, "Browse " .. v, keys[i] }
				end, vim.list_slice(layout, 1, 5))
			end

			local Section = {
				type = "text",
				oldfiles_directory = false,
				align = "center",
				fold_section = false,
				title = "Title",
				margin = 0.25,
				content = { "" },
				highlight = "Comment",
				default_color = "",
				oldfiles_amount = 0,
			}

			setmetatable(Section, {
				__call = function(self, init)
					return setmetatable(init, { __index = self })
				end,
			})

			startup.setup({
				header = Section({
					type = "text",
					-- align = "center",
					content = require("startup.headers").hydra_header,
					highlight = "DashboardHeader",
				}),
				buttons = Section({
					type = "mapping",
					-- align = "center",
					content = {
						-- { "  New file", 'call feedkeys("<leader>fn")', "f" },
						-- { "  Open last session", 'call feedkeys("<leader>pl")', "l" }, -- session load
						-- { "  Open current session", 'call feedkeys("<leader>pc")', "s" },
						{ "  Find file", 'call feedkeys("<leader>ff")', "q" }, -- fuzzy find
						{ "  Projects", 'call feedkeys("<leader>pf")', "p" }, -- open projects folder
						{ "  Recently opened files", "lua require('telescope.builtin').oldfiles()", "r" },
						-- { "  Update plugins", "Lazy sync", "u" },
						{ "  Edit neovim config", 'call feedkeys("<leader>nv")', "c" },
					},
					title = "Buttons",
				}),
				projects = Section({
					type = "mapping",
					title = "Projects",
					content = project_layout(),
				}),
				oldfiles = Section({
					type = "oldfiles",
					oldfiles_directory = true,
					oldfiles_amount = 2,
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
					paddings = { 5, 3, 2, 1 }, -- amount of empty lines before each section (must be equal to amount of sections)
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
					"projects",
					"oldfiles",
					-- "sessions",
				},
			})
		end,
	},
}
