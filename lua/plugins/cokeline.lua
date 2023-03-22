local function cokeline()
	local p = require("minimus.palette").hex
	local get_hex = require("cokeline.utils").get_hex
	local mappings = require("cokeline.mappings")

	local errors_fg = get_hex("DiagnosticError", "fg")
	local warnings_fg = get_hex("DiagnosticWarn", "fg")

	local red = vim.g.terminal_color_1
	local yellow = vim.g.terminal_color_3

	local circle_left = ""
	local circle_right = ""

	local components = {
		space = {
			text = " ",
			truncation = { priority = 1 },
		},
		separator = function(side)
			return {
				text = function(buffer)
					if side == "left" and (buffer.is_focused or buffer.is_first) then
						return circle_left
					elseif side == "right" and (buffer.is_focused or buffer.is_last) then
						return circle_right
					else
						return ""
					end
				end,
				fg = function(buffer)
					if buffer.is_focused then
						return p.turquoise
					else
						return p.gunmetal
					end
				end,
				bg = function(buffer)
					if (side == "left" and buffer.is_first) or (side == "right" and buffer.is_last) then
						return "none"
					else
						return p.gunmetal
					end
				end,
				truncation = { priority = 1 },
			}
		end,
		two_spaces = {
			text = "  ",
			truncation = { priority = 1 },
		},
		devicon = {
			text = function(buffer)
				return (mappings.is_picking_focus() or mappings.is_picking_close()) and buffer.pick_letter .. " "
					or buffer.devicon.icon
			end,
			fg = function(buffer)
				return buffer.is_focused and p.raisin_black
					or (mappings.is_picking_focus() and yellow)
					or (mappings.is_picking_close() and red)
					or buffer.devicon.color
			end,
			style = function(_)
				return (mappings.is_picking_focus() or mappings.is_picking_close()) and "italic,bold" or nil
			end,
			truncation = { priority = 1 },
		},
		index = {
			text = function(buffer)
				return buffer.index .. ": "
			end,
			truncation = { priority = 1 },
		},
		unique_prefix = {
			text = function(buffer)
				return buffer.unique_prefix
			end,
			fg = p.cool_gray,
			style = "italic",
			truncation = {
				priority = 3,
				direction = "left",
			},
		},
		filename = {
			text = function(buffer)
				return buffer.filename
			end,
			style = function(buffer)
				if buffer.is_focused then
					return "bold"
				end
				return nil
			end,
			fg = function(buffer)
				if buffer.is_focused then
					return p.raisin_black
				elseif buffer.diagnostics.errors ~= 0 then
					return errors_fg
				elseif buffer.diagnostics.warnings ~= 0 then
					return warnings_fg
				else
					return p.cool_gray
				end
			end,
			truncation = {
				priority = 2,
				direction = "left",
			},
		},
		diagnostics = {
			text = function(buffer)
				return (buffer.diagnostics.errors ~= 0 and "  " .. buffer.diagnostics.errors)
					or (buffer.diagnostics.warnings ~= 0 and "  " .. buffer.diagnostics.warnings)
					or ""
			end,
			fg = function(buffer)
				return (buffer.diagnostics.errors ~= 0 and errors_fg)
					or (buffer.diagnostics.warnings ~= 0 and warnings_fg)
					or nil
			end,
			truncation = { priority = 1 },
		},
		close_or_unsaved = {
			text = function(buffer)
				return buffer.is_modified and "●" or ""
			end,
			fg = function(_buffer)
				return nil
			end,
			delete_buffer_on_left_click = true,
			truncation = { priority = 1 },
		},
		padding = {
			text = function(buffer)
				return buffer.is_last and " " or ""
			end,
			bg = "none",
			fg = "none",
		},
		front_padding = {
			text = function(buffer)
				return buffer.is_focused and "" or " "
			end,
		},
	}

	return {
		show_if_buffers_are_at_least = 1,
		buffers = {
			-- filter_valid = function(buffer) return buffer.type ~= 'terminal' end,
			-- filter_visible = function(buffer) return buffer.type ~= 'terminal' end,
			new_buffers_position = "next",
		},
		-- rendering = {
		-- 	max_buffer_width = 30,
		-- },
		default_hl = {
			fg = function(buffer)
				return buffer.is_focused and p.raisin_black or p.cool_gray
			end,
			bg = function(buffer)
				return buffer.is_focused and p.turquoise or p.gunmetal
			end,
		},
		components = {
			components.separator("left"),
			components.space,
			components.space,
			components.devicon,
			-- components.space,
			-- components.index,
			components.unique_prefix,
			components.filename,
			components.diagnostics,
			components.two_spaces,
			components.close_or_unsaved,
			components.space,
			components.separator("right"),
			components.padding,
		},
	}
end

return {
	{
		"willothy/nvim-cokeline",
		-- dir = '~/projects/neovim/nvim-cokeline/',
		config = function()
			require("cokeline").setup(cokeline())
		end,
		lazy = false,
	},
}
