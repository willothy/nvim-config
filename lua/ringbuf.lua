local RingBuffer = {}

function RingBuffer.new(size)
	if size <= 0 then
		error("RingBuffer.new: size must be positive")
	end

	local rb = {
		_size = size,
		_buffer = {},
		_read = 1,
		_write = 1,
		_len = 0,
	}

	function rb:push(value)
		self._buffer[self._write] = value
		self._write = (self._write % self._size) + 1
		self._len = self._len + 1
	end

	function rb:pop()
		if self._len == 0 then
			return nil
		end
		local value = self._buffer[self._read]
		self._buffer[self._read] = nil
		self._read = (self._read % self._size) + 1
		if value then
			self._len = self._len - 1
		end
		return value
	end

	function rb:peek()
		if self._read == self._write then
			return nil
		end
		return self._buffer[self._read]
	end

	function rb:is_empty()
		return self._read == self._write
	end

	function rb:capacity()
		return self._size
	end

	function rb:len()
		return self._len
	end

	function rb:resize(new_size)
		if new_size <= 0 then
			error("RingBuffer.resize: size must be positive and non-zero")
		end
		if new_size < self._len then
			error("RingBuffer.resize: size must be greater than or equal to the number of elements in the buffer")
		end
		self._size = new_size
	end

	return rb
end

return RingBuffer
