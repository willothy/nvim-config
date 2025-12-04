local M = {}

-- Get or create reactive system
local rx = require("willothy.lib.reactive").create_system()

---@class StatuslineComponent
---@field get fun(): string Get cached component text
---@field hl string|fun(): string? Highlight group name or function that returns highlight group
---@field condition fun(): boolean? Function that returns whether to show component

---@class StatuslineConfig
---@field left StatuslineComponent[]
---@field center StatuslineComponent[]
---@field right StatuslineComponent[]

local config = {
  left = {},
  center = {},
  right = {},
}

---Render a single component
---@param component StatuslineComponent
---@return string
local function render_component(component)
  -- Check condition
  if component.condition and not component.condition() then
    return ""
  end

  -- Get text (already cached by reactive effect)
  local text = component.get()
  if text == "" then
    return ""
  end

  -- Apply highlight (can be string or function)
  if component.hl then
    local hl_name = type(component.hl) == "function" and component.hl() or component.hl
    if hl_name then
      return string.format("%%#%s#%s%%*", hl_name, text)
    end
  end

  return text
end

---Render the full statusline
---@return string
local function render_statusline()
  local parts = {}

  -- Left section
  for _, component in ipairs(config.left) do
    table.insert(parts, render_component(component))
  end

  -- Center section (with %= separator)
  if #config.center > 0 then
    table.insert(parts, "%=")
    for _, component in ipairs(config.center) do
      table.insert(parts, render_component(component))
    end
  end

  -- Right section (with %= separator if no center)
  if #config.right > 0 then
    table.insert(parts, "%=")
    for _, component in ipairs(config.right) do
      table.insert(parts, render_component(component))
    end
  end

  return table.concat(parts, "")
end

---Create a reactive component that auto-updates on state changes
---@param render_fn fun(): string Function to render the component (can read reactive state)
---@param opts? { hl?: string|fun(): string, condition?: fun(): boolean }
---@return StatuslineComponent
function M.component(render_fn, opts)
  opts = opts or {}

  -- Create a signal to hold the rendered text
  local get, set = rx.signal("")

  -- Set up reactive effect - automatically tracks dependencies and updates signal
  rx.effect(function()
    -- This re-runs whenever any signal accessed in render_fn changes
    local text = render_fn()
    set(text)
  end)

  return {
    get = get,  -- Returns cached text (updated by reactive effect)
    hl = opts.hl,
    condition = opts.condition,
  }
end

---Create a static component (no reactivity)
---@param text string|fun(): string
---@param opts? { hl?: string|fun(): string, condition?: fun(): boolean }
---@return StatuslineComponent
function M.static(text, opts)
  opts = opts or {}

  local render_fn = type(text) == "function" and text or function()
    return text
  end

  return {
    get = render_fn,  -- Just call render_fn directly each time
    hl = opts.hl,
    condition = opts.condition,
  }
end

---Setup the statusline
---@param user_config StatuslineConfig
---@param state_module table? Optional state module to watch for changes
function M.setup(user_config, state_module)
  config.left = user_config.left or {}
  config.center = user_config.center or {}
  config.right = user_config.right or {}

  -- Set statusline to call our render function
  vim.o.statusline = "%!v:lua.require('willothy.lib.statusline').render()"

  -- If state module provided, set up a SINGLE watcher for ALL reactive state changes
  if state_module then
    local redraw_timer = nil

    local function request_redraw()
      if redraw_timer then
        return  -- Already scheduled
      end

      redraw_timer = vim.defer_fn(function()
        vim.cmd.redrawstatus()
        redraw_timer = nil
      end, 16)  -- Batch all updates within 16ms window (60fps)
    end

    -- Single effect watches ALL state (dependency graph handles the rest)
    rx.effect(function()
      -- Read all state to track dependencies
      state_module.mode.get()
      state_module.git_branch.get()
      state_module.diagnostics.get()

      -- Request single batched redraw
      request_redraw()
    end)
  end
end

---Public render function (called by statusline)
---@return string
function M.render()
  return render_statusline()
end

---Get current configuration (for debugging)
---@return StatuslineConfig
function M.get_config()
  return vim.deepcopy(config)
end

return M
