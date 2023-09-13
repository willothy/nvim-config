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
---@field signal_values any[]
---@field signal_subscribers table<SignalId, Set>
---@field running_effect EffectId?
local Runtime

---@generic T
---@class Signal<T>
---@field rt Runtime
---@field id SignalId
local Signal

Runtime = {
  signal_values = {},
  running_effect = nil,
  signal_subscribers = {},
  effects = {},
}
Runtime.__index = Runtime

function Runtime:new()
  return setmetatable({
    signal_values = {},
    running_effect = nil,
    signal_subscribers = {},
    effects = {},
  }, self)
end

---@generic T
---@param init T
---@return Signal
function Runtime:create_signal(init)
  table.insert(self.signal_values, init)
  local id = #self.signal_values
  self.signal_subscribers[id] = self.signal_subscribers[id] or Set:new()
  return Signal:new(id, self)
end

---@param callback fun()
function Runtime:create_effect(callback)
  local id = #self.effects + 1
  self.effects[id] = callback
  self:run_effect(id)
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
  return setmetatable({ id = id, rt = rt }, self)
end

function Signal:get()
  local value = self.rt.signal_values[self.id]
  if self.rt.running_effect then
    self.rt.signal_subscribers[self.id]:insert(self.rt.running_effect)
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
  rt:create_effect(callback)
end

function M.with_runtime(fn)
  fn(rt)
end

M.named_signals = {}

function M.create_named_signal(name, init)
  if not M.named_signals[name] then
    M.named_signals[name] = M.create_signal(init)
  end
  return M.named_signals[name]
end

return M
