---@alias Rx.SignalId integer
---@alias Rx.EffectId integer

---@generic T
---@class Rx.Set<T>
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

---@class Rx.Runtime
---@field signal_values Rx.WeakTable
---@field signal_subscribers table<Rx.SignalId, Rx.Set>
---@field signal_id_free_list Rx.SignalId[]
---@field effects fun()[]
---@field running_effect Rx.EffectId?
---@field effect_dependencies table<Rx.EffectId, Rx.Set>
---@field effect_id_free_list Rx.EffectId[]
local Runtime

---@generic T
---@class Rx.Signal<T>
---@field rt Rx.Runtime
---@field id Rx.SignalId
local Signal

---@class Rx.WeakTable
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
---@return Rx.Signal
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
---@return Rx.EffectId
function Runtime:create_effect(callback)
  local id = table.remove(self.effect_id_free_list) or (#self.effects + 1)
  self.effects[id] = callback
  self.effect_dependencies[id] = Set:new()
  self:run_effect(id)
  return id
end

function Runtime:remove_effect(id)
  self.effects[id] = nil
  if self.effect_dependencies[id] ~= nil then
    self.effect_dependencies[id]:values():each(function(signal_id)
      self.signal_subscribers[signal_id]:remove(id)
    end)
    self.effect_dependencies[id] = nil
  end
  table.insert(self.effect_id_free_list, id)
end

function Runtime:run_effect(id)
  local effect = self.effects[id]
  vim.schedule(function()
    local last_effect = self.running_effect
    self.running_effect = id
    effect()
    self.running_effect = last_effect
  end)
end

Signal = {}

---@generic T
---@param id Rx.SignalId
---@param rt Rx.Runtime
---@return Rx.Signal<T>
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
  self.__index = self
  self.__call = self.get
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
  local val = fn(self.rt.signal_values[self.id])
  if val ~= nil then
    self.rt.signal_values[self.id] = val
  end
  self.rt.signal_subscribers[self.id]:values():each(function(effect_id)
    self.rt:run_effect(effect_id)
  end)
end

local rt = Runtime:new()

---@class Rx
local Rx = {}

function Rx._signal_count()
  return rt.signal_values:len()
end

function Rx.create_signal(init)
  return rt:create_signal(init)
end

function Rx.create_effect(callback)
  return rt:create_effect(callback)
end

---@param fn fun(rt: Rx.Runtime)
function Rx.with_runtime(fn)
  fn(rt)
end

Rx.Runtime = Runtime
Rx.Signal = Signal
Rx.Set = Set

return Rx
