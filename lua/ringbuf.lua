---@class Ringbuf
local Ringbuf = {}
Ringbuf.__index = Ringbuf

function Ringbuf:new(size, grow)
	local o = {}
	o.size = size
	o.buf = {}
	o.read = 1
	o.write = 1
	o.grow = grow or false
	setmetatable(o, Ringbuf)
	return o
end

function Ringbuf:push(item)
	if self:is_full() and self.grow then
		self:resize(self.size * 2)
	end
	self.buf[self.write] = item
	self.write = self.write + 1
	if self.write > self.size then
		self.write = 1
	end
end

function Ringbuf:pop()
	local item = self.buf[self.read]
	self.read = self.read + 1
	if self.read > self.size then
		self.read = 1
	end
	return item
end

function Ringbuf:swap(index1, index2)
	if not index1 then
		index1 = self.read - 1
	end
	if not index2 then
		index2 = self.read
	end
	self.buf[index1], self.buf[index2] = self.buf[index2], self.buf[index1]
end

function Ringbuf:is_empty()
	return self.read == self.write
end

function Ringbuf:is_full()
	return self.read == self.write + 1 or (self.read == 1 and self.write == self.size)
end

function Ringbuf:clear()
	self.read = 1
	self.write = 1
end

function Ringbuf:resize(size)
	self.size = size
end

return Ringbuf
