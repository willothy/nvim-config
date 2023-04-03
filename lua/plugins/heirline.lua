local p = require("minimus.palette").hex
local icons = require("willothy.icons")
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

local function handler(f, name)
	return {
		callback = f,
		name = name or ("handler_" .. (math.random() * 100)),
	}
end

local function heirline()
	local utils = require("heirline.utils")
	local conditions = require("heirline.conditions")

	local with = {
		__index = function(self, k)
			if k == "with" then
				return function(Component, opts)
					return utils.clone(Component, opts)
				end
			else
				return rawget(self, k)
			end
		end,
	}
	local Component = function(init)
		return setmetatable(init, with)
	end

	local hl = {
		A = function(_self)
			local mode = vim.fn.mode(1):sub(1, 1)
			return mode_map[mode][1]
		end,
		ANOBG = function(_self)
			local mode = vim.fn.mode(1):sub(1, 1)
			return {
				fg = mode_map[mode][1].bg,
				bg = "none",
			}
		end,
		AB = function(_self)
			local mode = vim.fn.mode(1):sub(1, 1)
			return {
				fg = mode_map[mode][1].bg,
				bg = mode_map[mode][2].bg,
			}
		end,
		B = function(_self)
			local mode = vim.fn.mode(1):sub(1, 1)
			return mode_map[mode][2]
		end,
		BC = function(_self)
			local mode = vim.fn.mode(1):sub(1, 1)
			return {
				fg = mode_map[mode][2].bg,
				bg = mode_map[mode][3].bg,
			}
		end,
		C = function(_self)
			local mode = vim.fn.mode(1):sub(1, 1)
			return mode_map[mode][3]
		end,
		NONE = { fg = "none", bg = "none", style = "none" },
	}
	setmetatable(hl, {
		__call = function(_self, component, highlight)
			return setmetatable(
				utils.clone(component, {
					hl = highlight,
				}),
				with
			)
		end,
	})

	local separators = {
		left = function(hl_)
			return Component({
				provider = "",
				hl = hl_,
			})
		end,
		right = function(hl_)
			return Component({
				provider = "",
				hl = hl_,
			})
		end,
	}

	local BG = function(component)
		return {
			hl = hl.C,
			component,
		}
	end

	local Align = { provider = "%=" }
	local Space = function(count)
		return setmetatable({ provider = string.rep(" ", count) }, with)
	end

	local Mode = Component({
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
		hl = hl.A,
		update = {
			"ModeChanged",
			pattern = "*:*",
			callback = vim.schedule_wrap(function()
				vim.cmd("redrawstatus")
			end),
		},
	})

	local Location = Component({
		provider = function(_self)
			local line = vim.fn.line(".")
			local col = vim.fn.col(".")
			local maxline = vim.fn.line("$")
			local width = (#string.format("%d", maxline)) + 6
			local s = string.format("%d:%d", line, col)

			local i = 0
			while true do
				if #s > width then
					break
				end
				if i % 2 == 0 then
					s = " " .. s
				else
					s = s .. " "
				end
				i = i + 1
			end

			return s
			-- return lpad(rpad(string.format("%d:%d", line, col), math.ceil(width / 2)), math.floor(width / 2))
		end,
		hl = hl.A,
	})

	local Copilot = Component({
		provider = function(_self)
			local client = require("copilot.client").get(true)
			if client == nil then
				return ""
			end
			-- require("nvim-web-devicons").get_icon_by_filetype("zig", {})
			return client and (icons.git.copilot .. " ") or ""
		end,
		hl = hl.C,
		on_click = handler(function()
			require("copilot.panel").open()
		end, "heirline_copilot"),
	})

	local Filetype = Component({
		provider = function(_self)
			return vim.bo.filetype ~= "" and vim.bo.filetype
				or vim.fn.fnamemodify(string.lower(vim.api.nvim_buf_get_name(0)), ":t")
		end,
		hl = hl.C,
	})

	local Devicon = Component({
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
	})

	local Harpoon = Component({
		Index = {
			provider = function(_self)
				local harpoon = require("harpoon.mark")
				local idx = harpoon.get_current_index()
				return idx or ""
			end,
			hl = hl.C,
		},
		Count = {
			provider = function(_self)
				local harpoon = require("harpoon.mark")
				local count = harpoon.get_length()
				return count or ""
			end,
			hl = hl.C,
			on_click = handler(function()
				require("harpoon.ui").toggle_quick_menu()
			end),
		},
		Hook = {
			provider = "ﯠ ",
			hl = hl.C,
			on_click = handler(function()
				require("harpoon.ui").toggle_quick_menu()
			end),
		},
	})

	local Git = Component({
		static = {
			icons = {
				branch = icons.git.branch,
				added = icons.git.diff.added,
				modified = icons.git.diff.modified,
				removed = icons.git.diff.removed,
			},
		},
		condition = conditions.is_git_repo,

		init = function(self)
			self.status_dict = vim.b.gitsigns_status_dict
			self.has_changes = self.status_dict.added ~= 0
				or self.status_dict.removed ~= 0
				or self.status_dict.changed ~= 0
		end,

		hl = hl.C,

		{ -- git branch name
			provider = function(self)
				return string.format("%s %s ", self.icons.branch, self.status_dict.head)
			end,
			hl = { fg = p.cool_gray },
		},
		{
			provider = function(self)
				local count = self.status_dict.added or 0
				return count > 0 and (self.icons.added .. count)
			end,
			hl = { fg = p.pale_turquoise },
		},
		{
			provider = function(self)
				return (
					(self.status_dict.added or 0) > 0
					and ((self.status_dict.removed or 0) > 0 or (self.status_dict.changed or 0) > 0)
				)
						and " "
					or ""
			end,
		},
		{
			provider = function(self)
				local count = self.status_dict.removed or 0
				return count > 0 and string.format("%s %s", self.icons.removed, count) or ""
			end,
			hl = { fg = p.red },
		},
		{
			provider = function(self)
				return ((self.status_dict.removed or 0) > 0 and (self.status_dict.changed or 0) > 0) and " " or ""
			end,
		},
		{
			provider = function(self)
				local count = self.status_dict.changed or 0
				return count > 0 and string.format("%s %s", self.icons.modified, count) or ""
			end,
			hl = { fg = p.lemon_chiffon },
		},
		{
			provider = " ",
			condition = function(self)
				return self.has_changes
			end,
		},
	})

	local FileName = Component({
		provider = function(_self)
			local filename = vim.fn.expand("%:t")
			local extension = vim.fn.expand("%:e")
			local icon, _icon_color =
				require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
			icon = icon and (icon .. " ") or ""
			local width = (#filename * 2) + #icon - 1 --vim.o.columns
			return "%-" .. width .. "(" .. string.format("%s%s", icon, filename) .. "%)"
		end,
		hl = hl.C,
	})

	local Left = Component({
		separators.left(hl.ANOBG),
		hl(Mode, hl.A),
		separators.right(hl.ANOBG),
		-- separators.right(hl.ANOBG):with({ condition = flip(conditions.is_git_repo) }),
		hl({
			Space(1),
			Git,
			condition = conditions.is_git_repo,
		}, hl.C),
		-- separators.right(hl.ANOBG):with({ condition = conditions.is_git_repo }),
		Harpoon.Hook,
		Harpoon.Count,
	})

	local Center = Component({
		FileName,
		--Align,
		-- setmetatable({
		-- 	hl(FileName, { fg = p.colombia_blue }),
		-- 	{
		-- 		update = { "LspAttach", "LspDetach" },
		-- 		provider = function(_self)
		-- 			local names = {}
		-- 			for _, server in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
		-- 				if server.name ~= "copilot" and server.name ~= "null-ls" then
		-- 					table.insert(names, server.name)
		-- 				end
		-- 			end
		-- 			local state = require("willothy.state")
		-- 			state.lsp.clients = names
		-- 			state.lsp.attached = #names > 0
		--
		-- 			--[[ " " .. ]]
		-- 			return string.format(" • %s", table.concat(names, ", "))
		-- 		end,
		-- 		condition = function()
		-- 			return #require("willothy.state").lsp.clients > 0
		-- 		end,
		-- 		hl = { fg = p.colombia_blue, bg = "none" },
		-- 		flexible = 1,
		-- 	},
		-- }, with):with({
		-- 	condition = function()
		-- 		return vim.bo.buflisted
		-- 	end,
		-- 	hl = { fg = p.colombia_blue, bg = "none" },
		-- }),
	})

	local Right = Component({
		hl({
			Space(1),
			Devicon,
			Space(1),
			Filetype,
			Space(1),
			Copilot,
			Space(1),
		}, hl.C),
		separators.left(hl.ANOBG),
		hl(Location, hl.A),
		separators.right(hl.ANOBG),
		-- flexible = 3,
	})

	local StatusLine = {
		-- flexible = 4,
		Left,
		Align,
		-- Center,
		-- Align,
		Right, --:with({ flexible = 2 }),
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
	},
}
