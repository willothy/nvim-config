local M = {}

---@class willothy.Rx
---@field signal fun(initial: any): fun(): any, fun(new_value: any): nil
---@field effect fun(effect_fn: fun()): nil

---Create a new reactive system instance
---@return willothy.Rx
function M.create_system()
  ---Current computation being tracked
  ---@type fun()|nil
  local current_effect = nil

  local signals = {}

  local function dispose()
    for dependencies in pairs(signals) do
      for effect in pairs(dependencies) do
        dependencies[effect] = nil
      end
      signals[dependencies] = nil
    end
  end

  ---Run a function with dependency tracking
  ---@param effect_fn fun() Function to track dependencies for
  local function run_effect(effect_fn)
    local prev_effect = current_effect
    current_effect = effect_fn
    effect_fn()
    current_effect = prev_effect
  end

  ---Create a new reactive value
  ---@generic T
  ---@param initial T Initial value
  ---@return fun(): T
  ---@return fun(new_value: T): nil
  local function signal(initial)
    local value = initial

    ---@type table<fun(), boolean>
    local dependencies = {}

    signals[dependencies] = true

    local function get()
      if current_effect then
        dependencies[current_effect] = true
      end
      return value
    end

    local function set(new_value)
      if value == new_value then
        return
      end

      value = new_value

      for effect in pairs(dependencies) do
        -- Remove from dependencies
        -- (will be added again when get() is called)
        dependencies[effect] = nil

        run_effect(effect)
      end
    end

    return get, set
  end

  return {
    signal = signal,
    effect = run_effect,
  }
end

return M
