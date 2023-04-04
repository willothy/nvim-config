---@alias K any
---@alias V any
---@alias R any
---@generic K, V, R
---@class Iter<K, V>
---@field map fun(self: Iter<K, V>, f: fun(k: K, v: V): R): Iter<K, R>
---@field filter fun(self: Iter<K, V>, f: fun(k: K, v: V): boolean): Iter<K, V>
---@field each fun(self: Iter<K, V>, f: fun(k: K, v: V))
---@field push fun(self: Iter<K, V>, v: V)
---@field finish fun(self: Iter<K, V>): table<K, V>
---@field extend fun(self: Iter<K, V>, other: Iter<K, V>): Iter<K, V>
local Iter = {}

function Iter:islist()
	return vim.tbl_islist(self)
end

---@generic T
---@param self Iter<T>
---@param v T
function Iter:push(v)
	table.insert(self, v)
end

---@generic T
---@param self Iter<T>
---@param idx number | nil
---@return T
function Iter:pop(idx)
	return table.remove(self, idx or #self)
end

---@generic K, V
---@param self Iter<K, V>
---@param other Iter<K, V>
function Iter:extend(other)
	for k, v in ipairs(other) do
		self[k] = v
	end
end

---@generic K, V
---@param init table<K, V>|nil
---@return Iter<K, V>
function Iter:new(init)
	if getmetatable(init) == Iter then
		return vim.deepcopy(init)
	end
	local new = init and vim.deepcopy(init) or {}
	setmetatable(new, self)
	self.__index = self
	return new
end

---@generic K, V
---@param self Iter<K, V>
---@return Iter iter
---Returns self if self is already an iterator, or creates an iterator from other
function Iter:from(other)
	if getmetatable(other) == self then
		return other
	else
		return Iter:new(other)
	end
end

---Calls `fn` on each value, modifying and returning self
---@generic K, V, R
---@param self Iter<K, V>
---@param fn fun(v: V): R
---@return Iter<K, R>
function Iter:map(fn)
  if self:islist() then
    for i, v in ipairs(self) do
      self[i] = fn(v)
    end
  else
    for k, v in pairs(self) do
      self[k] = fn(v)
    end
  end
	return self
end

---@generic K, V
---@param self Iter<K, V>
---@return Iter:{K, V}[]
---Turns a map into a list of {k, v} pairs
function Iter:enumerate()
	local res = Iter:new()
	for k, v in pairs(self) do
		res:push({ k, v })
	end
	return res
end

---@generic K, V
---@param self <`K`, `V`>
---The inverse of `enumerate`
---Turns a list of `{K, V}` pairs into a map
---@return Iter<K, V>
function Iter:remap()
	local res = Iter:new()
	for _, v in ipairs(self) do
		res[v[1]] = v[2]
	end
	return res
end

---@generic K, V
---Removes the iterator metatable, returning the underlying data
function Iter:collect()
	return setmetatable(self, nil)
end

---@generic K, V
---@param self Iter<K, V>
---@return Iter<K, V>
---Clones the iterator, and its underlying data
function Iter:clone()
	return Iter:new(self)
end

---@param self Iter
---@return Iter
---Reshapes the iterator using an accumulator
function Iter:reduce(fn, init)
	local acc = init
	for i, v in ipairs(self) do
		acc = fn(acc, v, vim.tbl_keys(self)[i])
	end
	return acc
end

function Iter:filter(fn)
  local res = Iter:new()
  for k, v in pairs(self) do
    if fn(v) then
      res[k] = v
    end
  end
  return res
end

return Iter

--[[ 
-- Contrived and inefficient example:
-- This is a zero indexed array
-- We need it to be 1-indexed (unfortunately),
-- because we want to turn it into a table.
local test_map = {
	["test"] = 0,
	["test2"] = 1,
	["test3"] = 2,
	["test4"] = 3,
	["aaaaaaaaaaa"] = 4,
	[""] = 5,
	[" "] = 6,
}

local mapped = Iter
	:new(test_map)
	-- increment the indices
	:map(function(v)
		return v + 1
	end)
	-- turn it into a list of {k, v} pairs
	:enumerate()
	-- swap the index and key
	:map(function(v)
		return { v[2], v[1] }
	end)
	-- remap (<K, V>[] => {K = V})
	:remap()
	-- deconstruct the iterator
	:collect()

-- is equivalent to

local reduced = Iter:new(test_map):enumerate():reduce(function(acc, v)
	acc[v[2] + 1] = v[1]
	return acc
end, {})

local t = Iter:new(test):map(function(v)
  return v .. "!"
end):collect()

print(reduced) => { "test", "test2", "test3", "test4", "aaaaaaaaaaa", "", " " } 
print(mapped) => { "test", "test2", "test3", "test4", "aaaaaaaaaaa", "", " " }
]]

