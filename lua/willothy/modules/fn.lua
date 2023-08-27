local M = {}

local function _telescope(_, picker, extension)
  return function(...)
    local t = require("telescope")
    local ext = t.extensions
    extension = extension or "menufacture"
    if ext[extension][picker] ~= nil then
      ext[extension][picker](...)
    elseif require("telescope.builtin")[picker] then
      require("telescope.builtin")[picker](...)
    elseif ext[picker] and ext[picker][picker] then
      ext[picker][picker](...)
    else
      vim.notify(string.format("unknown picker %s", picker))
    end
  end
end

M.telescope = setmetatable({}, {
  __call = _telescope,
  __index = _telescope,
})

---@param msg string
function M.notify_mini(msg, opts)
  local title = opts.title
  local level = opts.level or vim.log.levels.INFO
  require("noice.message.router").redirect(function()
    vim.notify(msg, level, {
      title = title,
    })
  end, {
    { filter = {}, view = "mini" },
  })
end

---@param view string
---@param msg string
---@param title string
function M.redirect(view, msg, title)
  require("noice.message.router").redirect(function()
    vim.notify(msg, vim.log.levels.INFO, {
      title = title or "Notify",
    })
  end, {
    { filter = {}, view = view },
  })
end

---@param msg string
---@param title string
function M.popup(msg, title)
  M.redirect("popup", msg, title)
end

function M.throttle(fn, delay)
  local timer = vim.uv.new_timer()
  local running = false

  -- the canary and proxy are used to ensure the timer is closed when the
  -- function is garbage collected
  local proxy = newproxy(false)
  local canary
  return function(...)
    canary = canary
      or debug.setmetatable(proxy, {
        __gc = vim.schedule_wrap(function()
          timer:stop()
          timer:close()
        end),
      })
    if canary and not running then
      running = true
      fn(...)
      timer:start(delay, 0, function()
        running = false
      end)
    end
  end
end

function M.debounce(fn, delay)
  local timer = vim.uv.new_timer()

  local proxy = newproxy(false)
  local canary
  return function(...)
    canary = canary
      or debug.setmetatable(proxy, {
        __gc = vim.schedule_wrap(function()
          timer:stop()
          timer:close()
        end),
      })
    if canary and timer:is_active() then
      timer:stop()
    end
    local args = { ... }
    timer:start(delay, 0, function()
      fn(unpack(args))
    end)
  end
end



return M
