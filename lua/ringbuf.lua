local vpns = vim.api.nvim_create_namespace("yankstack")

function vprint(text, buf)
	buf = buf or 0
	if type(text) ~= "string" then
		text = vim.inspect(text)
	end
	local caller_line = debug.getinfo(2).currentline
	vim.api.nvim_buf_set_extmark(buf, vpns, caller_line - 1, 0, {
		id = 1,
		virt_text = { { text, "LspInlayHint" } },
		virt_text_pos = "eol",
	})
end

---@class Ringbuf
local Ringbuf = {}
Ringbuf.__index = Ringbuf

function Ringbuf:new(size)
	local o = {}
	o.size = size
	o.buf = {}
	o.read = 1
	o.write = 1
	setmetatable(o, Ringbuf)
	return o
end

function Ringbuf:push(item)
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
	local new_buf = {}
	local i = 1
	while not self:is_empty() do
		new_buf[i] = self:pop()
		i = i + 1
	end
	self.buf = new_buf
	self.size = size
	self.read = 1
	self.write = i
end

return Ringbuf
