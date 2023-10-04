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

function M.debounce_leading(fn, ms)
  fn = vim.schedule_wrap(fn)
  local timer = vim.loop.new_timer()
  local running = false

  local canary = newproxy(true)
  getmetatable(canary).__gc = function()
    -- close the timer handle when the function is GC'd
    if not timer:is_closing() then
      timer:close()
    end
  end

  return function(...)
    timer:start(ms, 0, function()
      running = false
    end)

    -- just to ensure that the canary is captured in the closure
    if canary and not running then
      running = true
      fn(...)
    end
  end
end

function M.debounce_trailing(fn, ms)
  local timer = vim.loop.new_timer()
  local canary = newproxy(true)

  getmetatable(canary).__gc = function()
    -- close the timer handle when the function is GC'd
    if not timer:is_closing() then
      timer:close()
    end
  end

  return function(...)
    local args = vim.F.pack_len(...)
    -- just to ensure that the canary is captured in the closure
    if canary then
      timer:start(
        ms,
        0,
        vim.schedule_wrap(function()
          fn(vim.F.unpack_len(args))
        end)
      )
    end
  end
end

local _id = 1
local function next_id()
  local id = _id
  _id = _id + 1
  return id
end
function M.make_clickable(fn, text, id)
  if not _G.__willothy_handlers then
    _G.__willothy_handlers = {}
    setmetatable(_G.__willothy_handlers, {
      __call = function(self, param_id)
        return self[param_id]
      end,
    })
  end
  id = id or next_id()
  _G.__willothy_handlers[tostring(id)] = fn
  local handler = "v:lua.__willothy_handlers'" .. id .. "'"
  return ("%%%s@%s@%s%%X"):format(id, handler, text), id
end

local Range = function(start_row, start_col, end_row, end_col)
  return {
    start_row = start_row,
    start_col = start_col,
    end_row = end_row,
    end_col = end_col,

    contains = function(self, other)
      return self.start_row <= other.start_row
        -- and self.start_col <= other.start_col
        and self.end_row >= other.end_row
      -- and self.end_col >= other.end_col
    end,
  }
end

function M.diagnostics()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(win)

  local node = vim.treesitter.get_node({
    bufnr = buf,
    pos = {
      cursor[1] - 1,
      cursor[2],
    },
  })
  if not node then
    return
  end
  local range = Range(vim.treesitter.get_node_range(node))

  return vim
    .iter(vim.diagnostic.get(buf))
    :filter(function(diag)
      local diag_range =
        Range(diag.lnum, diag.col, diag.end_lnum, diag.end_col)
      return range:contains(diag_range)
    end)
    :totable()
end

function M.map_range(input_start, input_end, output_start, output_end, input)
  local input_length = input_end - input_start
  local output_length = output_end - output_start
  local max = math.max(output_start, output_end)
  local min = math.min(output_start, output_end)
  return math.min(
    max,
    math.max(
      min,
      output_start + ((input - input_start) / input_length) * output_length
    )
  )
end

return M
