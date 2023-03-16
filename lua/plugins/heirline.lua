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


	local function hl(section)
		return function(self)
			local mode = vim.fn.mode(1):sub(1, 1)
			return mode_map[mode][section]
		end
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
			-- return utils.surround({ '', '' }, hl(1),
			-- 	{ provider = function() return "%2(" .. self.mode_names[self.mode] .. "%)" end })
			return "%2(" .. self.mode_names[self.mode] .. "%)"
			-- return self.mode_names[self.mode]
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

	local TabLine = {
		hl = hl(3)
	}

	local StatusLine = {
		hl = hl(3),
		utils.surround({ '', '' }, function() return hl(1)().bg end, Mode),
		Align,
	}

	return {
		statusline = StatusLine,
		tabline = TabLine
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
	enabled = false
} }
