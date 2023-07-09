---@class Deque
---@field private _buffer table
local Deque = {}
Deque.__index = Deque

---@return Deque
function Deque.new()
  return setmetatable({
    _buffer = {},
    _read = 1,
    _write = 1,
    _len = 0,
  }, Deque)
end

function Deque:push_front(value)
  self._read = self._read - 1
  if self._read < 1 then self._read = #self._buffer + 1 end
  self._buffer[self._read] = value
  self._len = self._len + 1
end

function Deque:push_back(value)
  self._buffer[self._write] = value
  self._write = self._write + 1
  self._len = self._len + 1
end

function Deque:pop_front()
  if self._len == 0 then return nil end
  local value = self._buffer[self._read]
  self._buffer[self._read] = nil
  self._read = self._read + 1
  if self._read > #self._buffer then self._read = 1 end
  self._len = self._len - 1
  return value
end

function Deque:pop_back()
  if self._len == 0 then return nil end
  self._write = self._write - 1
  if self._write < 1 then self._write = #self._buffer end
  local value = self._buffer[self._write]
  self._buffer[self._write] = nil
  self._len = self._len - 1
  return value
end

function Deque:peek_front()
  if self._len == 0 then return nil end
  return self._buffer[self._read]
end

function Deque:peek_back()
  if self._len == 0 then return nil end
  local index = self._write - 1
  if index < 1 then index = #self._buffer end
  return self._buffer[index]
end

function Deque:is_empty() return self._len == 0 end

function Deque:capacity() return #self._buffer end

function Deque:len() return self._len end

return Deque
