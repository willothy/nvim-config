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

---@generic T, R
---@param self Iter<T>
---@param f fun(x: T, acc: R): R
---@param init R
---@return R
function Iter:collect(f, init)
	local acc = init
	for _, val in ipairs(self) do
		acc = f(val, acc)
	end
	return acc
end

---@generic K, V, R
---@param self Iter<K, V>
---@param f fun(k: K, v: V): R
---@return Iter<K, R>
function Iter:map(f)
	local r = Iter:new({})
	for k, v in pairs(self) do
		r[k] = f(k, v)
	end
	return r
end

---@generic K, V
---@param self Iter<K, V>
---@param f fun(k: K, v: V): boolean
---@return Iter<K, V>
function Iter:filter(f)
	local r = Iter:new({})
	Iter.each(self, function(k, v)
		if f(k, v) == true then
			r[k] = v
		end
	end)
	return r
end

function Iter:islist()
	return vim.tbl_islist(self)
end

---@generic K, V
---@param self Iter<K, V>
---@param f fun(k: K, x: V)
function Iter:each(f)
	if vim.tbl_islist(self) then
		for i, v in ipairs(self) do
			f(i, v)
		end
	else
		for k, v in pairs(self) do
			f(k, v)
		end
	end
end

---@generic T
---@param self Iter<T>
---@param v T
function Iter:push(v)
	table.insert(self, v)
end

---@generic K, V
---@param self Iter<K, V>
---@return table<K, V> | V[] result
function Iter:finish()
	return setmetatable(self, {})
end

---@generic K, V
---@param self Iter<K, V>
---@param other Iter<K, V>
---@return Iter<K, V>
function Iter:extend(other)
	for k, v in ipairs(other) do
		self[k] = v
	end
	return self
end

---@generic K, V
---@param init table<K, V>
---@return Iter<K, V>
function Iter.new(init)
	local self = setmetatable(init or {}, { __index = Iter })
	return self
end

---@class Iter
return Iter
