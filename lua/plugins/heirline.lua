local p = require('minimus.palette').hex
local mode_colors = {
	normal = {
		{ fg = p.raisin_black, bg = p.turquoise },
		{ fg = p.text,         bg = p.gunmetal },
		{ fg = p.cool_gray,    bg = p.none },
	},
	insert = {
		{ fg = p.raisin_black, bg = p.pale_azure },
		{ fg = p.text,         bg = p.gunmetal },
		{ fg = p.cool_gray,    bg = p.none },
	},
	visual = {
		{ fg = p.raisin_black, bg = p.lemon_chiffon },
		{ fg = p.text,         bg = p.gunmetal },
		{ fg = p.cool_gray,    bg = p.none },
	},
	replace = {
		{ fg = p.raisin_black, bg = p.lavender_pink },
		{ fg = p.text,         bg = p.gunmetal },
		{ fg = p.cool_gray,    bg = p.none },
	},
	command = {
		{ fg = p.raisin_black, bg = p.peach },
		{ fg = p.text,         bg = p.gunmetal },
		{ fg = p.cool_gray,    bg = p.none },
	},
	inactive = {
		{ fg = p.blueGray3, bg = p.gunmetal },
		{ fg = p.blueGray3, bg = p.gunmetal },
		{ fg = p.blueGray3, bg = p.none },
	}
}


local mode_map = {
	n = mode_colors.normal,
	i = mode_colors.insert,
	v = mode_colors.visual,
	V = mode_colors.visual,
	["\22"] = mode_colors.visual,
	c = mode_colors.command,
	s = mode_colors.visual,
	S = mode_colors.visual,
	["\19"] = mode_colors.visual,
	R = mode_colors.replace,
	r = mode_colors.replace,
	["!"] = mode_colors.command,
	t = mode_colors.command,
}


local function heirline()
	local utils = require('heirline.utils')
	local conditions = require('heirline.conditions')

	local function hl(section)
		return function(self)
			local mode = vim.fn.mode(1):sub(1, 1)
			return mode_map[mode][section]
		end
	end

	local A = function(Component)
		return utils.surround({ '', '' }, function() return hl(1)().bg end, Component)
	end

	local B = function(Component)
		return utils.surround({ '', '' }, function() return hl(2)().bg end, Component)
	end

	local C = function(Component)
		return utils.surround({ '', '' }, function() return hl(3)().bg end, Component)
	end

	local BG = function(Component)
		return {
			hl = hl(3),
			Component
		}
	end

	local Align = { provider = "%=" }
	local Space = { provider = " " }

	local Mode = {
		static = {
			mode_names = {
				-- change the strings if you like it vvvvverbose!
				n = "Normal",
				no = "Normal?",
				nov = "Normal?",
				noV = "Normal?",
				["no\22"] = "Normal?",
				niI = "I-Normal",
				niR = "R-Normal",
				niV = "V-Normal",
				nt = "T-Normal",
				v = "Visual",
				vs = "Visual-S",
				V = "V-Line",
				Vs = "V-Line-S",
				["\22"] = "V-Block",
				["\22s"] = "V-Block-S",
				s = "Select",
				S = "S-Line",
				["\19"] = "S-Block",
				i = "Insert",
				ic = "C-Insert",
				ix = "X-Insert",
				R = "Replace",
				Rc = "C-Replace",
				Rx = "X-Replace",
				Rv = "V-Replace",
				Rvc = "VC-Replace",
				Rvx = "VX-Replace",
				c = "Command",
				cv = "Vim Ex",
				r = "...",
				rm = "More",
				["r?"] = "?",
				["!"] = "!",
				t = "Terminal",
			}
		},
		init = function(self)
			self.mode = vim.fn.mode(1) -- :h mode()
		end,
		provider = function(self)
			return "%2( " .. self.mode_names[self.mode] .. " %)"
		end,
		hl = hl(1),
		update = {
			"ModeChanged",
			pattern = "*:*",
			callback = vim.schedule_wrap(function()
				vim.cmd("redrawstatus")
			end),
		}
	}

	local FileIcon = {
		init = function(self)
			local filename = self.filename
			local extension = vim.fn.fnamemodify(filename, ":e")
			self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension,
				{ default = true })
		end,
		provider = function(self)
			return self.icon and (self.icon .. ' ')
		end,
		hl = function(self)
			return { fg = self.icon_color }
		end
	}

	local FileName = {
		provider = function(self)
			local filename = vim.fn.fnamemodify(self.filename, ':.')
			if filename == '' then return '[No Name]' end
			if not conditions.width_percent_below(#filename, 0.25) then
				filename = vim.fn.pathshorten(filename)
			end
			return filename
		end,
		hl = { fg = utils.get_highlight("Directory").fg },
	}

	local Buffer = {
		init = function(self)
			self.filename = vim.api.nvim_buf_get_name(0)
		end,
		FileIcon,
		FileName,
		-- { provider = '%<' } -- statusline is cut here if there's not enough space
	}

	local Buffers = {

	}

	local TabLine = {
		Buffers
	}

	local StatusLine = {
		A(Mode),
		BG(Align),
	}

	return {
		statusline = BG(StatusLine),
		-- tabline = BG(TabLine)
	}
end

return { {
	"rebelot/heirline.nvim",
	config = function()
		require('heirline').setup(heirline())
	end,
	init = function()
		vim.cmd("set laststatus=3")
	end,
	lazy = true,
	event = 'UiEnter',
	enabled = true
} }
