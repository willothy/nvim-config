if require('lazy.core.config').plugins['lualine.nvim'] then
	local sep_options = {
		circle_left = '',
		circle_right = '',
		moon_left = '',
		moon_right = '',
	}

	local separators = {
		left = sep_options.circle_left,
		right = sep_options.circle_right,
	}

	require('lualine').setup({
		options = {
			theme = 'minimus',
			icons_enabled = true,
			ignore_focus = {
				'netrw',
				'Floaterm',
				'ToggleTerm',
				'Trouble',
				'telescopeprompt',
				'Mason',
			},
			disabled_filetypes = {},
			always_divide_middle = true,
			globalstatus = true,
		},
		sections = {
			-- left side
			lualine_a = { {
				'mode',
				separator = separators,
			} },
			lualine_b = { {
				'branch',
				separator = {
					left = '',
					right = sep_options.circle_right,
				}
			} },
			lualine_c = { {
				'filename',
				symbols = {
					modified = '●',
					readonly = '',
					unnamed = ' [No Name]',
					newfile = ' [New File]',
				},
			} },
			-- right side
			lualine_x = { { 'encoding' } },
			lualine_y = {
				{
					'filetype',
					separator = {
						left = sep_options.circle_left,
						right = ''
					},
				},
				{
					function()
						local client = require('copilot.client').get(true)
						if client == nil then
							return ''
						end
						local status = client
							and require('copilot.api')
							.check_status(client, {}, function()
							end)
							or false
						local hl = status
							and '%#CopilotStatusOk#'
							or '%#CopilotStatusError#'
						local icon = require('nvim-web-devicons')
							.get_icon_by_filetype('zig', {})
						return string.format('%s%s ', hl, icon)
					end,
				},
			},
			lualine_z = { {
				'location',
				separator = separators,
			} },
		},
		inactive_sections = {
			-- left side
			lualine_a = { {
				'mode',
				separator = separators,
			} },
			lualine_b = { {
				'branch',
				separator = separators,
			} },
			lualine_c = { {} },
			-- right side
			lualine_x = { {} },
			lualine_y = { {} },
			lualine_z = { {} },
		},
		tabline = {
			-- left side
			lualine_a = {
				{
					'buffers',
					use_mode_colors = true,
					--buffers_color = {
					--    active = active_buf_color_gen('a'),
					--},
					component_separators = {
						left = '',
						right = sep_options.circle_right,
					},
					section_separators = {
						left = sep_options.circle_right,
						right = sep_options.circle_right,
					},
					separator = {
						left = sep_options.circle_left,
						right = sep_options.circle_right
					},
					symbols = {
						modified = ' ●',
						alternate_file = ' ',
						directory = '',
					}
				}
			},
			lualine_b = { {} },
			lualine_c = { {
				'harpoon',
				separator = {
					left = sep_options.circle_left,
					right = sep_options.circle_right,
				},
			} },
			-- right side
			lualine_x = {
				{
					'diagnostics',
					separator = '',
					update_in_insert = true,
				},
			},
			lualine_y = { {
				'diff',
				show_all_if_any = true,
				separator = {
					left = sep_options.circle_left,
					right = '',
				},
				symbols = {
					added = ' ',
					modified = ' ',
					removed = ' ',
				}
			} },
			lualine_z = { {
				'datetime',
				style = "%H:%M",
				separator = separators,
			} },
		},
	})
end
