local Queue = require("dsa.queue")

local Receiver = {}

function Receiver:new()
  local o = { _buffer = Queue:new() }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Receiver:recv()
  if self._buffer:is_empty() then
    return nil
  else
    return self._buffer:pop()
  end
end

-- Creates a new multi producer, multi consumer channel
local mpmc = function()
  local readers = {}

  local tx = {}

  function tx:send(val)
    for _, reader in pairs(readers) do
      reader._buffer:push(val)
    end
  end

  local rx = { _buffer = Queue:new() }
  readers[1] = rx

  function rx:clone()
    local reader = { _buffer = Queue:new() }
    readers[#readers + 1] = reader
    return reader
  end

  function rx:recv() return self._buffer:pop() end

  return tx, rx
end

return {
  mpmc = mpmc,
}
