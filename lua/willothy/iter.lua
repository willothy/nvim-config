---@generic T
---@class Iterator<T>
---@field next fun(self: Iterator<T>): T
local Iterator = {}

---@generic T
---@param self Iterator<T>
---@return T[]
---Consumes the iterator, returning an array of values
function Iterator:collect()
	local result = {}
	local next = nil
	repeat
		next = self:next()
		if next then
			table.insert(result, next)
		end
	until next == nil
	return result
end

---@generic T, R
---@param self Iterator<T>
---@param init R
---@param fn fun(acc: R, v: T): R
---@return R
---Consumes the iterator, folding values into an accumulator
function Iterator:fold(init, fn)
	local function fold_inner(acc)
		local next = self:next()
		if next == nil then
			return acc
		end
		return fold_inner(fn(acc, next))
	end
	return fold_inner(init)
end

---@generic T
---@param self Iterator<T>
---@param fn fun(v: T): boolean
---@return T | nil
function Iterator:find(fn)
	local next = nil
	repeat
		next = self:next()
		if next and fn(next) then
			return next
		end
	until next == nil
	return nil
end

---@generic T
---@param self Iterator<T>
---@param fn fun(v: T): boolean
---@return number | nil
function Iterator:position(fn)
	local next = nil
	local i = 0
	repeat
		next = self:next()
		i = i + 1
		if next and fn(next) then
			return i
		end
	until next == nil
	return nil
end

---@generic T
---@param self Iterator<T>
---@param fn fun(v: T): boolean
---@return boolean
---Consumes the iterator, and returns true if every value in the iterator matches the predicate
function Iterator:all(fn)
	local next = nil
	repeat
		next = self:next()
		if next and not fn(next) then
			return false
		end
	until next == nil
	return true
end

local impl = function(v)
	return setmetatable(v, { __index = Iterator })
end

---@generic T
---@class Iter<T>: Iterator<T>
---@field private i number
---@field next fun(self: Iter<T>): T
---Iterates over a list-like table
local Iter = impl({
	i = 0,
	next = function(self)
		self.i = self.i + 1
		return self.inner[self.i]
	end,
	new = function(self, tbl)
		return setmetatable({ inner = tbl }, { __name = "iter", __index = self })
	end,
})
function Iterator:new(tbl)
	return Iter:new(tbl or {})
end

---@generic T, R
---@class Map<T>: Iterator<T>
---@field private inner Iterator<T>
---@field private fn fun(v: T): R
---@field next fun(self: Map<T>): R
local Map = impl({
	next = function(self)
		local next = self.inner:next()
		if next == nil then
			return nil
		end
		return self.fn(next)
	end,
	new = function(self, tbl, fn)
		return setmetatable({ inner = tbl, fn = fn }, { __name = "map", __index = self })
	end,
})
function Iterator:map(fn)
	return Map:new(self, fn)
end

---@generic T
---@class Filter<T>: Iterator<T>
---@field private inner Iterator<T>
---@field private fn fun(v: T): boolean
---@field next fun(self: Filter<T>): T
local Filter = impl({
	next = function(self)
		local next = self.inner:next()
		if next == nil then
			return nil
		end
		if self.fn(next) == true then
			return next
		else
			return self:next()
		end
	end,
	new = function(self, tbl, fn)
		return setmetatable({ inner = tbl, fn = fn }, { __name = "filter", __index = self })
	end,
})
function Iterator:filter(fn)
	return Filter:new(self, fn)
end

---@generic T
---@class Chain<T>: Iterator<T>
---@field private inner Iterator<T>
---@field private current number
---@field next fun(self: Chain<T>): T
local Chain = impl({
	current = 1,
	next = function(self)
		local next = self.inner[self.current]:next()
		if next == nil then
			self.current = self.current + 1
			if self.inner[self.current] == nil then
				return nil
			end
			return self:next()
		end
		return next
	end,
	new = function(self, ...)
		return setmetatable({ inner = { ... } }, { __name = "chain", __index = self })
	end,
})
function Iterator:chain(...)
	return Chain:new(self, ...)
end

---@generic T
---@class Enumerate<T>: Iterator<T>
---@field private inner Iterator<T>
---@field private i number
---@field next fun(self: Enumerate<T>): { number, T }
local Enumerate = impl({
	i = 0,
	next = function(self)
		self.i = self.i + 1
		local next = self.inner:next()
		if next == nil then
			return nil
		end
		return { self.i, next }
	end,
	new = function(self, tbl)
		return setmetatable({ inner = tbl }, { __name = "enumerate", __index = self })
	end,
})
function Iterator:enumerate()
	return Enumerate:new(self)
end

---@generic T
---@param tbl T[]
---@return Iter<T>
function table.iter(tbl)
	return Iter:new(tbl or {})
end

return Iterator
