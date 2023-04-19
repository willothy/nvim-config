local Task = {}

function Task.new(proto)
	local self = proto or {}
	setmetatable(self, { __index = Task })
	return self
end

function Task:fn(fn)
	self.fn = fn
	return self
end

function Task:callback(callback)
	self.callback = callback
	return self
end

function Task:spawn()
	local handle = vim.loop.new_thread(self.fn)
	handle:join()
end

return Task
