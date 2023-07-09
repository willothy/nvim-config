local Queue = {}
Queue.__index = Queue

function Queue:new()
  local o = { _buffer = {}, _read = 1, _write = 1 }
  return setmetatable(o, Queue)
end

function Queue:push(val)
  self._buffer[self._write] = val
  self._write = self._write + 1
end

function Queue:pop()
  local val = self._buffer[self._read]
  self._buffer[self._read] = nil
  self._read = self._read + 1
  return val
end

function Queue:len() return self._write - self._read end

function Queue:is_empty() return self:len() == 0 end

return Queue
