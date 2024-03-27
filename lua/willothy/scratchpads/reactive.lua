---@class Rx.Signal<T>
---@field cx Rx.Runtime
---@field subscribers table<Rx.Effect, boolean>
local Signal = {}

Signal.__index = Signal
Signal.__metatable = "Rx.Signal"

---@generic T
---@param cx Rx.Runtime
---@param init T
---@return Rx.Signal<T>
function Signal.new(cx, init)
  local subscribers = {}
  local function get()
    if cx.running_effect then
      subscribers[cx.running_effect] = true
    end
    return init
  end
  local function set(value)
    init = value
    for id in pairs(subscribers) do
      cx:run_effect(id)
    end
  end
  return setmetatable({
    cx = cx,
    subscribers = setmetatable(subscribers, {
      __mode = "k",
    }),
    get = get,
    set = set,
  }, Signal)
end

function Signal:subscribe(effect)
  self.subscribers[effect] = true
  effect.dependencies[self] = true
end

function Signal:unsubscribe(effect)
  self.subscribers[effect] = nil
  effect.dependencies[self] = nil
end

---@class Rx.Effect
---@field cx Rx.Runtime
---@field dependencies table<Rx.Signal, boolean>
local Effect = {}

---@param cx Rx.Runtime
---@return Rx.Effect
function Effect.new(cx, fn)
  local self = setmetatable({
    cx = cx,
    fn = fn,
    dependencies = {},
  }, Effect)
  return self
end

function Effect:dependency(signal)
  self.dependencies[signal] = true
  signal.subscribers[self] = true
end

function Effect:cleanup()
  for signal in pairs(self.dependencies) do
    signal.subscribers[self] = nil
    self.dependencies[signal] = nil
  end
end

---@alias Rx.EffectId integer

---@class Rx.Runtime
---@field running_effect Rx.EffectId
---@field effects table<Rx.EffectId, fun()>
---@field next_effect_id Rx.EffectId
---@field effect_dependencies table<Rx.EffectId, table<Rx.Signal, boolean>>
local Runtime = {}

Runtime.__index = Runtime
Runtime.__metatable = "Rx.Runtime"

---@return Rx.Runtime
function Runtime.new()
  local self = {
    next_effect_id = 1,
    effects = {},
  }

  return setmetatable(self, Runtime)
end

---@generic T
---@param init T
---@return Rx.Signal<T>
function Runtime:create_signal(init)
  return Signal.new(self, init)
end

function Runtime:create_effect(fn)
  local id = self.next_effect_id
  self.next_effect_id = id + 1

  self.effects[id] = fn

  return id
end

function Runtime:run_effect(id)
  local effect = self.effects[id]
  if effect then
    local prev = self.running_effect
    self.running_effect = id
    effect()
    self.running_effect = prev
  end
end

function Runtime:dispose()
  for id in pairs(self.effects) do
    self.effects[id] = nil
  end
end

local rt = Runtime.new()

local signal = rt:create_signal(1)
