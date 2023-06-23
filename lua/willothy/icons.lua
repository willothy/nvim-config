local M = {}

M.kinds = {
	Method = "",
	Function = "󰡱",
	Constructor = "",
	Field = "ﰠ",
	Variable = "",
	Class = "",
	Property = "ﰠ",
	Interface = "",
	Enum = "",
	EnumMember = "",
	Reference = "",
	Struct = "",
	Event = "",
	Constant = "",
	Keyword = "",

	Module = "",
	Package = "",
	Namespace = "",

	Unit = "",
	Value = "",
	String = "",
	Number = "",
	Boolean = "",
	Array = "",
	Object = "",
	Key = "",
	Null = "",

	Text = "",
	Snippet = "",
	Color = "",
	File = "",
	Folder = "",
	Operator = "",
	TypeParameter = "",
}

M.kinds.spaced = setmetatable({}, {
	__index = function(_, key)
		return rawget(M.kinds, key) .. " "
	end,
})

M.diagnostics = {
	errors = "󰞏", --
	warnings = "", -- "",--
	hints = "", --"󰮔",
	info = "",
}
M.diagnostics.Error = M.diagnostics.errors
M.diagnostics.Warn = M.diagnostics.warnings
M.diagnostics.Hint = M.diagnostics.hints
M.diagnostics.Info = M.diagnostics.info

M.lsp = {
	action_hint = "",
}

M.git = {
	diff = {
		added = "",
		modified = "󰆗",
		removed = "",
	},
	signs = {
		bar = "┃",
		untracked = "•",
	},
	branch = "",
	copilot = "", --"",
	copilot_err = "",
	copilot_warn = "",
}

M.dap = {
	stopped = "",
	running = "",
	paused = "",
	breakpoint = "",
	start = "", -- 
	breakpoint_condition = "",
	breakpoint_rejected = "",
	log_point = "",
}

M.actions = {
	close_hexagon = "󰅜",
	close2 = "⌧",
	close_round = "󰅙",
	close_outline = "󰅚",
	close = "🞫",
}

M.fold = {
	open = "",
	closed = "",
}

M.separators = {
	angle_quote = {
		left = "«",
		right = "»",
	},
	chevron = {
		left = "",
		right = "",
		down = "",
	},
	circle = {
		left = "",
		right = "",
	},
	arrow = {
		left = "",
		right = "",
	},
	slant = {
		left = "",
		right = "",
	},
}

M.misc = {
	datetime = "󱛡 ",
	modified = "●",
	fold = "⮓",
	newline = "",
	circle = "",
	circle_filled = "",
	circle_slash = "",
	ellipse = "",
	kebab = "",
	tent = "⛺",
	comma = "ﯠ",
	hook = "󰛢",
	hook_disabled = "󰛣",
}

return M
