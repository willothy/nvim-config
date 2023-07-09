describe("ringbuf", function()
  local RingBuffer = require("ringbuf")

  it(
    "throws an error when created with size 0",
    function() assert(pcall(RingBuffer.new, 0) == false) end
  )

  it(
    "throws an error when created with a negative size",
    function() assert(pcall(RingBuffer.new, -5) == false) end
  )

  it("creates a new RingBuffer with a positive size", function()
    local buffer = RingBuffer.new(5)
    assert(type(buffer) == "table")
    assert(buffer._size == 5)
    assert(buffer._read == 1)
    assert(buffer._write == 1)
    assert(buffer._read == 1)
  end)

  it("pushes elements to the buffer", function()
    local buffer = RingBuffer.new(5)
    buffer:push(1)
    assert(buffer._read == 1, buffer._read)
    assert(buffer._write == 2, buffer._write)
    buffer:push(2)
    assert(buffer._read == 1, buffer._read)
    assert(buffer._write == 3, buffer._write)
    buffer:push(3)
    assert(buffer._read == 1)
    assert(buffer._write == 4)
  end)

  it("pops elements from the buffer", function()
    local buffer = RingBuffer.new(5)
    buffer:push(1)
    buffer:push(2)
    buffer:push(3)
    local v = buffer:pop()
    assert(v == 1, v or "nil")
    assert(buffer._read == 2)
    assert(buffer._write == 4)
    assert(buffer:pop() == 2)
    assert(buffer._read == 3)
    assert(buffer._write == 4)
    assert(buffer:pop() == 3)
    assert(buffer._read == 4)
    assert(buffer._write == 4)
  end)

  it("returns nil when removing from an empty buffer", function()
    local buffer = RingBuffer.new(5)
    assert(buffer:pop() == nil)
  end)

  it("returns the first element without removing it", function()
    local buffer = RingBuffer.new(5)
    buffer:push(1)
    buffer:push(2)
    buffer:push(3)
    assert(buffer:peek() == 1)
    assert(buffer._read == 1)
    assert(buffer._write == 4)
  end)

  it(
    "overwrites old elements when pushing more elements than the buffer size",
    function()
      local buffer = RingBuffer.new(4)
      buffer:push(1)
      buffer:push(2)
      buffer:push(3)
      buffer:push(4)
      buffer:push(5)
      assert(buffer._buffer[1] == 5, buffer._buffer[1])
      assert(buffer._buffer[2] == 2, buffer._buffer[2])
      assert(buffer._buffer[3] == 3, buffer._buffer[3])
      assert(buffer._buffer[4] == 4, buffer._buffer[4])
    end
  )

  it("counts elements accurately", function()
    local buffer = RingBuffer.new(4)
    assert(buffer:len() == 0, buffer:len())
    buffer:push(1)
    assert(buffer:len() == 1, buffer:len())
    buffer:push(2)
    assert(buffer:len() == 2, buffer:len())
    buffer:push(3)
    assert(buffer:len() == 3, buffer:len())
    buffer:push(4)
    assert(buffer:len() == 4, buffer:len())
    buffer:push(5)
    assert(buffer:len() == 5, buffer:len())
    buffer:pop()
    assert(buffer:len() == 4, buffer:len())
    buffer:pop()
    assert(buffer:len() == 3, buffer:len())
    buffer:pop()
    assert(buffer:len() == 2, buffer:len())
    buffer:pop()
    assert(buffer:len() == 1, buffer:len())
  end)
end)

describe("mpmc", function()
  local mpmc = require("dsa.channel").mpmc

  it("creates a new mpmc channel", function()
    local tx, rx = mpmc()

    assert(type(tx) == "table")
    assert(type(tx.send) == "function")
    assert(type(rx) == "table")
    assert(type(rx.recv) == "function")
  end)

  it("sends and receives values", function()
    local tx, rx = mpmc()

    tx:send(1)
    tx:send(2)
    tx:send(3)

    local function recv(expect)
      local v = rx:recv()
      assert(v == expect, v or "nil")
    end

    recv(1)
    recv(2)
    recv(3)
  end)
end)
