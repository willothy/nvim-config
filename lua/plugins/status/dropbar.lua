local icons = require("willothy.icons")

return {
	{
		"Bekaboo/dropbar.nvim",
		opts = {
			icons = {
				kinds = icons.kinds,
				ui = {
					bar = {
						separator = " %#NormalNC#" .. icons.separators.angle_quote.right .. " ",
						extends = " %#NormalNC#…",
					},
				},
			},
			bar = {
				padding = {
					left = 0,
					right = 1,
				},
			},
			menu = {
				keymaps = {
					q = function()
						local api = require("dropbar.api")
						local menu = api.get_current_dropbar_menu()
						if not menu then
							return
						end
						menu:close()
					end,
					["<Esc>"] = function()
						local api = require("dropbar.api")
						local menu = api.get_current_dropbar_menu()
						if not menu then
							return
						end
						menu:close()
					end,
					["<LeftMouse>"] = function()
						local api = require("dropbar.api")
						local menu = api.get_current_dropbar_menu()
						if not menu then
							return
						end
						local mouse = vim.fn.getmousepos()
						if mouse.winid ~= menu.win then
							local parent_menu = api.get_dropbar_menu(mouse.winid)
							if parent_menu and parent_menu.sub_menu then
								parent_menu.sub_menu:close()
							end
							if vim.api.nvim_win_is_valid(mouse.winid) then
								vim.api.nvim_set_current_win(mouse.winid)
							end
							return
						end
						menu:click_at({ mouse.line, mouse.column }, nil, 1, "l")
					end,
					["<CR>"] = function()
						local menu = require("dropbar.api").get_current_dropbar_menu()
						if not menu then
							return
						end
						local cursor = vim.api.nvim_win_get_cursor(menu.win)
						local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
						if component then
							menu:click_on(component, nil, 1, "l")
						end
					end,
				},
			},
		},
	},
}
