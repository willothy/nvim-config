local Nui = {
	Menu = require("nui.menu"),
	Popup = require("nui.popup"),
}

---@class Item
---@field name string
---@field on_submit fun()
local Item = {
	name = "",
	on_submit = function() end,
	on_focus = function() end,
	type = "item",
}
Item.__index = Item

function Item:new(name, on_submit, on_focus)
	local o = { name = name, on_submit = on_submit, on_focus = on_focus }
	setmetatable(o, self)
	return o
end

---@class Menu
---@field title string
---@field entries Entry[]
local Menu = {
	title = "",
	entries = {},
	type = "menu",
}
Menu.__index = Menu

---@return Menu
function Menu:new(title)
	local o = { title = title, entries = {} }
	setmetatable(o, self)
	return o
end

function Menu:add_entry(entry)
	table.insert(self.entries, entry)
end

function Menu:remove_entry(idx)
	table.remove(self.entries, idx)
end

function Menu:with_submenu(submenu)
	self:add_entry(submenu)
	return self
end

function Menu:with_item(name, on_submit, on_focus)
	self:add_entry(Item:new(name, on_submit, on_focus))
	return self
end

---@return NuiMenu
function Menu:build(parent)
	local lines = {}
	local max_len = 0
	local result
	for _, entry in ipairs(self.entries) do
		if entry.type == "item" then
			table.insert(lines, Nui.Menu.item(entry.name, { on_submit = entry.on_submit, on_focus = entry.on_focus }))
			if #entry.name > max_len then
				max_len = #entry.name
			end
		elseif entry.type == "menu" then
			table.insert(
				lines,
				Nui.Menu.item(entry.title .. " >", {
					on_submit = function()
						entry:build(result):mount()
					end,
					on_focus = function() end,
				})
			)
			if #entry.title > max_len then
				max_len = #entry.title
			end
		end
	end
	result = Nui.Menu({
		position = {
			row = 2,
			col = 2,
		},
		relative = "cursor",
		size = {
			width = math.max(max_len, 20),
			height = math.min(math.max(3, #lines), 10),
		},
		border = {
			style = "rounded",
			text = {
				top = self.title,
			},
		},
	}, {
		lines = lines,
		keymap = {
			close = { "q", "<Esc>" },
			submit = { "<CR>" },
			focus_next = { "<Tab>", "j", "<Down>" },
			focus_prev = { "<S-Tab>", "k", "<Up>" },
		},
		max_width = 20,
		on_submit = function(item)
			if item.on_submit then
				item.on_submit()
			end
		end,
		on_close = function()
			if result.parent then
				result.parent:mount()
			end
		end,
		on_change = function(item, _menu)
			if item.on_focus then
				item.on_focus()
			end
		end,
	})
	result:on(require("nui.utils.autocmd").event.BufLeave, function()
		result:unmount()
	end)
	result.parent = parent
	return result
end

return Menu
