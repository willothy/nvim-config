---@alias SignalId integer
---@alias EffectId integer

---@generic T
---@class Set<T>
local Set = {}
Set.__index = Set

function Set:new()
  return setmetatable({}, self)
end

---@generic T
---@param value T
---@return boolean
function Set:has(value)
  return self[value] ~= nil
end

---@generic T
---@param value T
function Set:insert(value)
  self[value] = value
end

---@generic T
---@param value T
function Set:remove(value)
  self[value] = nil
end

---@generic T
---@return Iter
function Set:values()
  return vim.iter(self)
end

---@class Runtime
---@field signal_values WeakTable
---@field signal_subscribers table<SignalId, Set>
---@field signal_id_free_list SignalId[]
---@field effects fun()[]
---@field running_effect EffectId?
---@field effect_dependencies table<EffectId, Set>
---@field effect_id_free_list EffectId[]
local Runtime

---@generic T
---@class Signal<T>
---@field rt Runtime
---@field id SignalId
local Signal

---@class WeakTable
local WeakTable = {}
WeakTable.__mode = "v"
WeakTable.__index = WeakTable

function WeakTable:new()
  return setmetatable({}, self)
end

function WeakTable:len()
  local len = 0
  for _ in pairs(self) do
    len = len + 1
  end
  return len
end

function WeakTable:has(key)
  return rawget(self, key) ~= nil
end

function WeakTable:insert(key, value)
  rawset(self, key, value)
end

function WeakTable:remove(key)
  rawset(self, key, nil)
end

function WeakTable:get(key)
  return rawget(self, key)
end

function WeakTable:push(value)
  rawset(self, self:len() + 1, value)
end

Runtime = {}
Runtime.__index = Runtime

function Runtime:new()
  return setmetatable({
    signal_values = WeakTable:new(),
    signal_subscribers = {},
    signal_id_free_list = {},
    running_effect = nil,
    effects = {},
    effect_dependencies = {},
    effect_id_free_list = {},
  }, self)
end

---@generic T
---@param init T
---@return Signal
function Runtime:create_signal(init)
  if type(init) == "function" then
    init = init()
  end
  local id = table.remove(self.signal_id_free_list) or self.signal_values:len()
  self.signal_values:insert(id, init)
  self.signal_subscribers[id] = self.signal_subscribers[id] or Set:new()
  return Signal:new(id, self)
end

---@param callback fun()
---@return EffectId
function Runtime:create_effect(callback)
  local id = table.remove(self.effect_id_free_list) or (#self.effects + 1)
  self.effects[id] = callback
  self.effect_dependencies[id] = Set:new()
  self:run_effect(id)
  return id
end

function Runtime:remove_effect(id)
  self.effects[id] = nil
  self.effect_dependencies[id]:values():each(function(signal_id)
    self.signal_subscribers[signal_id]:remove(id)
  end)
  self.effect_dependencies[id] = nil
  table.insert(self.effect_id_free_list, id)
end

function Runtime:run_effect(id)
  local effect = self.effects[id]
  local last_effect = self.running_effect
  self.running_effect = id
  effect()
  self.running_effect = last_effect
end

Signal = {}
Signal.__index = Signal

---@generic T
---@param id SignalId
---@param rt Runtime
---@return Signal<T>
function Signal:new(id, rt)
  local proxy = newproxy(true)
  getmetatable(proxy).__gc = function()
    rt.signal_subscribers[id]:values():each(function(sub)
      rt.effect_dependencies[sub]:remove(id)
    end)
    rt.signal_subscribers[id] = nil
    rt.signal_values[id] = nil
    table.insert(rt.signal_id_free_list, id)
  end
  return setmetatable({
    id = id,
    rt = rt,
    _proxy = proxy,
  }, self)
end

function Signal:get()
  local value = self.rt.signal_values[self.id]
  if self.rt.running_effect then
    self.rt.signal_subscribers[self.id]:insert(self.rt.running_effect)
    self.rt.effect_dependencies[self.rt.running_effect]:insert(self.id)
  end
  return value
end

---@generic T
---@param value T
function Signal:set(value)
  self.rt.signal_values[self.id] = value
  self.rt.signal_subscribers[self.id]:values():each(function(effect_id)
    self.rt:run_effect(effect_id)
  end)
end

---@generic T
---@param fn fun(value: T): T
function Signal:update(fn)
  self.rt.signal_values[self.id] = fn(self.rt.signal_values[self.id])
  self.rt.signal_subscribers[self.id]:values():each(function(effect_id)
    self.rt:run_effect(effect_id)
  end)
end

local rt = Runtime:new()

local M = {}

function M.create_signal(init)
  return rt:create_signal(init)
end

function M.create_effect(callback)
  return rt:create_effect(callback)
end

function M.with_runtime(fn)
  fn(rt)
end

return M
