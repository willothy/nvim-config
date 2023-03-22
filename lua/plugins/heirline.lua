local p = require("minimus.palette").hex
local mode_colors = {
	normal = {
		{ fg = p.raisin_black, bg = p.turquoise },
		{ fg = p.text, bg = p.gunmetal },
		{ fg = p.cool_gray, bg = p.none },
	},
	insert = {
		{ fg = p.raisin_black, bg = p.pale_azure },
		{ fg = p.text, bg = p.gunmetal },
		{ fg = p.cool_gray, bg = p.none },
	},
	visual = {
		{ fg = p.raisin_black, bg = p.lemon_chiffon },
		{ fg = p.text, bg = p.gunmetal },
		{ fg = p.cool_gray, bg = p.none },
	},
	replace = {
		{ fg = p.raisin_black, bg = p.lavender_pink },
		{ fg = p.text, bg = p.gunmetal },
		{ fg = p.cool_gray, bg = p.none },
	},
	command = {
		{ fg = p.raisin_black, bg = p.peach },
		{ fg = p.text, bg = p.gunmetal },
		{ fg = p.cool_gray, bg = p.none },
	},
	inactive = {
		{ fg = p.blueGray3, bg = p.gunmetal },
		{ fg = p.blueGray3, bg = p.gunmetal },
		{ fg = p.blueGray3, bg = p.none },
	},
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
	local utils = require("heirline.utils")
	local conditions = require("heirline.conditions")

	local function hl(section)
		return function(self)
			local mode = vim.fn.mode(1):sub(1, 1)
			return mode_map[mode][section]
		end
	end

	local A = function(Component, opt)
		local opts = opt or {
			first = true,
			last = true,
		}
		local left = opts.first and "" or ""
		local right = opts.last and "" or ""
		return utils.surround({ left, right }, function()
			return hl(1)().bg
		end, Component)
	end

	local B = function(Component, opt)
		local opts = opt or {
			first = true,
			last = true,
		}
		local left = opts.first and "" or ""
		local right = opts.last and "" or ""
		return utils.surround({ left, right }, function()
			return hl(2)().bg
		end, Component)
	end

	local C = function(Component, opt)
		local opts = opt or {
			first = true,
			last = true,
		}
		local left = opts.first and "" or ""
		local right = opts.last and "" or ""
		return utils.surround({ left, right }, function()
			return hl(3)().bg
		end, Component)
	end

	local BG = function(Component)
		return {
			hl = hl(3),
			Component,
		}
	end

	local Align = { provider = "%=" }
	local Space = function(count)
		return { provider = string.rep(" ", count) }
	end

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
			},
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
		},
	}

	local Location = {
		provider = function(_self)
			local line = vim.fn.line(".")
			local col = vim.fn.col(".")
			return string.format(" %d:%d ", line, col)
		end,
		hl = hl(1),
	}

	local Copilot = {
		provider = function(_self)
			local client = require("copilot.client").get(true)
			if client == nil then
				return ""
			end
			local status = client and require("copilot.api").check_status(client, {}, function() end) or false
			local copilot_hl = status and "%#CopilotStatusOk#" or "%#CopilotStatusError#"
			local icon = require("nvim-web-devicons").get_icon_by_filetype("zig", {})
			return string.format("%s%s", copilot_hl, icon)
		end,
		hl = hl(2),
	}

	local Filetype = {
		provider = function(_self)
			return vim.bo.filetype
		end,
		hl = hl(2),
	}

	local Devicon = {
		init = function(self)
			local filename = vim.fn.expand("%")
			local extension = vim.fn.fnamemodify(filename, ":e")
			self.icon, self.icon_color =
				require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
		end,
		provider = function(self)
			return self.icon and (self.icon .. " ")
		end,
		hl = function(self)
			return { fg = self.icon_color }
		end,
	}

	local Harpoon = {
		Index = {
			provider = function(_self)
				local harpoon = require("harpoon.mark")
				local idx = harpoon.get_current_index()
				return idx or ""
			end,
			hl = hl(3),
		},
		Count = {
			provider = function(_self)
				local harpoon = require("harpoon.mark")
				local count = harpoon.get_length()
				return count or ""
			end,
			hl = hl(3),
		},
		Hook = {
			provider = "ﯠ",
			hl = hl(3),
		},
	}

	local StatusLine = {
		A(Mode),
		Space(1),
		Harpoon.Hook,
		Harpoon.Index,
		BG(Align),
		B({
			Space(1),
			Devicon,
			Space(1),
			Filetype,
			Space(2),
			Copilot,
			Space(1),
		}, {
			first = true,
		}),
		A(Location),
	}

	return {
		statusline = BG(StatusLine),
		-- tabline = BG(TabLine)
	}
end

return {
	{
		"rebelot/heirline.nvim",
		config = function()
			require("heirline").setup(heirline())
		end,
		init = function()
			vim.cmd("set laststatus=3")
		end,
		lazy = true,
		event = "UiEnter",
		enabled = true,
	},
}
