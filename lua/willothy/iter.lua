---@generic T
---@class Iterator<T>
---@field next fun(self: Iterator<T>): T
local Iterator = setmetatable({}, {
	__index = function(self, k)
		if type(k) == "number" then
			return rawget(self, k)
		end
	end,
})

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

---@generic T
---@param self Iterator<T>
---@param fn fun(v: T)
function Iterator:for_each(fn)
	local next = self:next()
	while next ~= nil do
		fn(next)
		next = self:next()
	end
end

---@generic T
---@param self Iterator<T>
---@param n number
---@return T | nil
function Iterator:nth(n)
	local next = nil
	local i = 0
	repeat
		next = self:next()
		i = i + 1
	until next == nil or i == n
	return next
end

---@generic I, T
---@param v Iterator<T>
---@return I<T>
local impl = function(v)
	return setmetatable(v, { __index = Iterator })
end

---@generic T
---@class Iter<T>: Iterator<T>
---@field private i number
---@field next fun(self: Iter<T>): T|nil
---@field new fun(self: Iter<T>, tbl: T[]): Iter<T>
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
---@generic T
---@param tbl T[]
---@return Iter<T>
function Iterator:new(tbl)
	return Iter:new(tbl or {})
end

---@generic T, R
---@class Map<T, R>: Iterator<T>
---@field private inner Iterator<T>
---@field private fn fun(v: T): R
---@field next fun(self: Map<T>): R | nil
---@field new fun(self: Map<T>, tbl: Iterator<T>, fn: fun(v: T): R): Map<T>
local Map = impl({
	next = function(self)
		local next = self.inner:next()
		if next == nil then
			return nil
		end
		return self.fn(next)
	end,
	new = function(self, tbl, fn)
		return setmetatable({ fn = fn, inner = tbl }, { __name = "map", __index = self })
	end,
})
---@generic T, R
---@param self Iterator<T>
---@param fn fun(v: T): R
---@return Map<T, R>
function Iterator:map(fn)
	return Map:new(self, fn)
end

---@generic T
---@class Filter<T>: Iterator<T>
---@field private inner Iterator<T>
---@field private fn fun(v: T): boolean
---@field next fun(self: Filter<T>): T | nil
---@field new fun(self: Filter<T>, tbl: Iterator<T>, fn: fun(v: T): boolean): Filter<T>
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
		return setmetatable({ inner = tbl, fn = fn }, {
			__name = "filter",
			__index = self,
		})
	end,
})
---@generic T
---@param fn fun(v: T): boolean
---@return Filter<T>
function Iterator:filter(fn)
	return Filter:new(self, fn)
end

---@generic T
---@class Chain<T>: Iterator<T>
---@field private inner Iterator<T>
---@field private current number
---@field next fun(self: Chain<T>): T | nil
---@field new fun(self: Chain<T>, ...: Iterator<T>): Chain<T>
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
		return setmetatable({ inner = { ... } }, {
			__name = "chain",
			__index = self,
		})
	end,
})
---@generic T
---@vararg Iterator<T>
---@return Chain<T>
function Iterator:chain(...)
	return Chain:new(self, ...)
end

---@generic T
---@class Enumerate<T>: Iterator<T>
---@field private inner Iterator<T>
---@field private i number
---@field next fun(self: Enumerate<T>): { number, T } | nil
---@field new fun(self: Enumerate<T>, tbl: Iterator<T>): Enumerate<T>
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
		return setmetatable({ inner = tbl }, {
			__name = "enumerate",
			__index = self,
		})
	end,
})
---@generic T
---@return Enumerate<T>
function Iterator:enumerate()
	return Enumerate:new(self)
end

---@generic T, R
---@class FilterMap<T, R>: Iterator<T>
---@field private inner Iterator<T>
---@field private fn fun(v: T): R | nil
---@field next fun(self: FilterMap<T, R>): R | nil
---@field new fun(self: FilterMap<T, R>, tbl: Iterator<T>, fn: fun(v: T): R | nil): FilterMap<T, R>
local FilterMap = impl({
	next = function(self)
		local next = self.inner:next()
		if next == nil then
			return nil
		end
		local val = self.fn(next)
		if val == nil then
			return self:next()
		end
		return self.map(next)
	end,
	new = function(self, tbl, fn)
		return setmetatable({ inner = tbl, fn = fn }, {
			__name = "filtermap",
			__index = self,
		})
	end,
})
---@generic T, R
---@param fn fun(v: T): R | nil
---@return FilterMap<T, R>
function Iterator:filter_map(fn)
	return FilterMap:new(self, fn)
end

---@generic T
---@class Skip<T>: Iterator<T>
---@field private inner Iterator<T>
---@field private n number
---@field private i number
---@field next fun(self: Skip<T>): T | nil
---@field new fun(self: Skip<T>, tbl: T[], n: number): Skip<T>
local Skip = impl({
	next = function(self)
		local next = self.inner:next()
		if next == nil then
			return nil
		end
		if self.i < self.n then
			self.i = self.i + 1
			return self:next()
		end
		return next
	end,
	new = function(self, tbl, n)
		return setmetatable({ inner = tbl, n = n, i = 0 }, {
			__name = "skip",
			__index = self,
		})
	end,
})
---@generic T
---@param n number
---@return Skip<T>
function Iterator:skip(n)
	return Skip:new(self, n)
end

---@generic T
---@class Take<T>: Iterator<T>
---@field private inner Iterator<T>
---@field private n number
---@field private i number
---@field next fun(self: Take<T>): T | nil
---@field new fun(self: Take<T>, tbl: T[], n: number): Take<T>
local Take = impl({
	next = function(self)
		local next = self.inner:next()
		if next == nil then
			return nil
		end
		if self.i < self.n then
			self.i = self.i + 1
			return next
		end
		return nil
	end,
	new = function(self, tbl, n)
		return setmetatable({ inner = tbl, n = n, i = 0 }, {
			__name = "take",
			__index = self,
		})
	end,
})
---@generic T
---@param n number
---@return Take<T>
function Iterator:take(n)
	return Take:new(self, n)
end

---@generic T
---@class Cycle<T>: Iterator<T>
---@field private inner Iterator<T>
---@field private clone Iterator<T>
---@field next fun(self: Cycle<T>): T | nil
---@field new fun(self: Cycle<T>, tbl: Iterator<T>): Cycle<T>
local Cycle = impl({
	next = function(self)
		local next = self.inner:next()
		if next == nil then
			self.inner = vim.deepcopy(self.copy)
			next = self.inner:next()
		end
		return next
	end,
	new = function(self, tbl)
		return setmetatable({
			inner = tbl,
			copy = vim.deepcopy(tbl),
		}, {
			__name = "cycle",
			__index = self,
		})
	end,
})
---@generic T
---@return Cycle<T>
function Iterator:cycle()
	return Cycle:new(self)
end

---@generic T, A
---@class Zip<T, A>: Iterator<T>
---@field private inner { Iterator<T>, Iterator<R> }
---@field next fun(self: Zip<T>): { T, A } | nil
local Zip = impl({
	next = function(self)
		-- inner is a table of iterators
		local next = {}
		local l = self.inner[1]:next()
		if l == nil then
			return nil
		end
		table.insert(next, l)
		local r = self.inner[2]:next()
		if r == nil then
			return nil
		end
		table.insert(next, r)
		return next
	end,
	new = function(self, l, r)
		return setmetatable({ inner = { l, r } }, {
			__name = "zip",
			__index = self,
		})
	end,
})
---@generic T, A
---@param iter1 Iterator<T>
---@param iter2 Iterator<A>
---@return Zip<T, A>
function Iterator:zip(iter1, iter2)
	return Zip:new(self, iter1, iter2)
end

---@generic T, A
---@class Unzip<T, A>: Iterator<T>
---@field private inner Iterator<{ T, A }>
local Unzip = impl({
	next = function(self)
		local next = self.inner:next()
		if next == nil then
			return nil
		end
		return next
	end,
	new = function(self, tbl)
		local last = nil
		local l = tbl:map(function(v)
			if last == nil then
				last = v
				return v[1]
			else
				local tmp = last
				last = nil
				return tmp[1]
			end
		end)
		local r = tbl:map(function(v)
			if last == nil then
				last = v
				return v[2]
			else
				local tmp = last
				last = nil
				return tmp[2]
			end
		end)
		return setmetatable({ inner = l }, {
			__name = "unzip",
			__index = self,
		}),
			setmetatable({ inner = r }, {
				__name = "unzip",
				__index = self,
			})
	end,
})
---@generic T, A
---@return Unzip<T, A>
function Iterator:unzip()
	return Unzip:new(self)
end

---@generic T, R
---@class Intersperse<T, R>: Iterator<T>
---@field private inner Iterator<T>
---@field private sep Iterator<R>
---@field private i number
---@field next fun(self: Intersperse<T, R>): T | R | nil
local Intersperse = impl({
	next = function(self)
		self.i = self.i + 1
		if self.i % 2 ~= 0 then
			return self.inner:next()
		else
			return self.sep:next()
		end
	end,
	new = function(self, tbl, sep)
		return setmetatable({ inner = tbl, sep = sep, i = 0 }, {
			__name = "intersperse",
			__index = self,
		})
	end,
})
---@generic T, R
---@param sep Iterator<R>
---@return Intersperse<T, R>
function Iterator:intersperse(sep)
	return Intersperse:new(self, sep)
end

---@generic T
---@param tbl T[]
---@return Iter<T>
function table.iter(tbl)
	return Iter:new(tbl or {})
end

---@generic T
---@return Iterator<T>
function Iterator:clone()
	return setmetatable({
		inner = self.inner,
	}, getmetatable(self))
end

local function tests()
	local test = {
		"hello",
		"world",
		"this",
		"is",
		"a",
		"test",
	}

	local function describe(name, fn, expected)
		print(name)
		local ok, err = pcall(fn)
		if not ok then
			return err
		end
		if vim.deep_equal(err, expected) then
			return "pass"
		else
			return ("fail: " .. string.format("%s, expected %s", vim.inspect(err), vim.inspect(expected)))
		end
	end

	print(describe("iter", function()
		local i = table.iter(test)
		return i:next()
	end, "hello"))

	print(describe("map", function()
		local i = table.iter(test):map(function(v)
			return v .. "!"
		end)
		return i:next()
	end, "hello!"))

	print(describe("clone", function()
		local i = table.iter(test)
		local i2 = i:clone()
		return { i:next(), i2:next() }
	end, { "hello", "hello" }))

	print(describe("take", function()
		local i = table.iter(test):take(2)
		return { i:next(), i:next(), i:next() }
	end, { "hello", "world", nil }))

	print(describe("cycle", function()
		local i = table.iter(test):skip(4):cycle()
		return i:take(4):collect()
	end, { "a", "test", "a", "test" }))

	print(describe("nth", function()
		local i = table.iter(test):nth(2)
		return i
	end, "world"))

	print(describe("zip", function()
		local i = table.iter(test):zip(table.iter(test))
		return i:next()
	end, { "hello", "hello" }))

	print(describe("unzip", function()
		local i1, i2 = table.iter(test):zip(table.iter(test)):unzip()
		return { i1:next(), i2:next() }
	end, { "hello", "hello" }))

	print(describe("intersperse", function()
		local i = table.iter(test):intersperse(table.iter({ "!", "!", "!", "!", "!" }))
		return i:take(10):collect()
	end, { "hello", "!", "world", "!", "this", "!", "is", "!", "a", "!" }))

	print(describe("collect", function()
		local i = table.iter(test):collect()
		return i
	end, test))

	print(describe("fold", function()
		local i = table.iter(test):intersperse(table.iter({ " " }):cycle():take(#test - 1)):fold("", function(acc, v)
			return acc .. v
		end)
		return i
	end, "hello world this is a test"))

	print(describe("index", function()
		local i = table.iter(test):map(function(v)
			return v
		end)

		local i1 = getmetatable(i).__name
		print(i1)

		return {}
	end, {}))
end

tests()

return Iterator
