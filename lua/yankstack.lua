---@class Stack
local Stack = {}
Stack.__index = Stack

function Stack:new()
	local o = {}
	setmetatable(o, Stack)
	return o
end

function Stack:push(item)
	table.insert(self, item)
end

function Stack:insert(index, item)
	table.insert(self, index, item)
end

function Stack:set(index, item)
	self[index] = item
end

function Stack:pop()
	return table.remove(self)
end

function Stack:swap(index1, index2)
	if not index1 then
		index1 = #self - 1
	end
	if not index2 then
		index2 = #self
	end
	self[index1], self[index2] = self[index2], self[index1]
end

function Stack:get(index)
	return self[index]
end

function Stack:get_or_insert(index, item)
	if self[index] == nil then
		self[index] = item
	end
	return self[index]
end

function Stack:is_empty()
	return #self == 0
end

function Stack:length()
	return #self
end

function Stack:clear()
	for i = 1, #self do
		self[i] = nil
	end
end

function Stack:join(sep)
	return table.concat(self, sep)
end

return Stack
