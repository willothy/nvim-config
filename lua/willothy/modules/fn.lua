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

function M.clamp(min, max, value)
  return math.min(max, math.max(min, value))
end

function M.interpolate(start, finish, t)
  return start + (finish - start) * t
end

function M.animate(start, finish, callback, opts)
  opts = opts or {}
  local duration = opts.duration or 500
  local fps = opts.fps or 60
  local start_time = vim.loop.now()
  local timer = vim.loop.new_timer()

  local interval = 1000 / fps
  timer:start(10, interval, function()
    local elapsed = vim.loop.now() - start_time
    local t = M.clamp(0, 1, elapsed / duration)
    local v = M.interpolate(start, finish, t)
    callback(v)
    if t == 1 and not timer:is_closing() then
      timer:stop()
      timer:close()
    end
  end)

  return function()
    if not timer:is_closing() then
      timer:stop()
      timer:close()
    end
  end
end

local function min(a, b, c)
  local min_val = a

  if b < min_val then
    min_val = b
  end
  if c < min_val then
    min_val = c
  end

  return min_val
end

function M.visual_range()
  local cursorline, cursorcol = unpack(vim.api.nvim_win_get_cursor(0))
  cursorcol = cursorcol + 1
  local mode = vim.api.nvim_get_mode().mode
  if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
    return cursorline, cursorline, cursorcol, cursorcol
  end

  local vstart = vim.fn.line("v") or cursorline
  local vstart_col = vim.fn.col("v")

  if vstart > cursorline then
    vstart, cursorline = cursorline, vstart
    vstart_col, cursorcol = cursorcol, vstart_col
  end

  if mode == "V" then
    cursorcol = vim.fn.col("$") - 1
    vstart_col = 1
  end

  return math.min(vstart, cursorline),
    math.max(vstart, cursorline),
    vstart_col,
    cursorcol
end

---Taken from telescope.nvim
---@param s1 string
---@param s2 string
---@return number distance
function M.str_distance(s1, s2)
  if s1 == s2 then
    return 0
  end
  if s1:len() == 0 then
    return s2:len()
  end
  if s2:len() == 0 then
    return s1:len()
  end
  if s1:len() < s2:len() then
    s1, s2 = s2, s1
  end

  local t = {}
  for i = 1, #s1 + 1 do
    t[i] = { i - 1 }
  end

  for i = 1, #s2 + 1 do
    t[1][i] = i - 1
  end

  local cost
  for i = 2, #s1 + 1 do
    for j = 2, #s2 + 1 do
      cost = (s1:sub(i - 1, i - 1) == s2:sub(j - 1, j - 1) and 0) or 1
      t[i][j] = min(t[i - 1][j] + 1, t[i][j - 1] + 1, t[i - 1][j - 1] + cost)
    end
  end

  return t[#s1 + 1][#s2 + 1]
end

---@class Willothy.CommandOpts.Subcommand
---@field complete nil|fun(arg: string, line: string): string[]
---@field execute string|fun(...: string)

---@class Willothy.CommandOpts: vim.api.keyset.user_command
---@field subcommands table<string, Willothy.CommandOpts.Subcommand>?
---@field command string|fun()?

---@param name string
---@param opts Willothy.CommandOpts
function M.create_command(name, opts)
  if not opts then
    return
  end
  local command = opts.command
  opts.command = nil

  local subcommands = opts.subcommands
  opts.subcommands = nil
  if subcommands then
    opts.nargs = "*"

    local names = vim.tbl_keys(subcommands) --[[ @as string[] ]]

    function opts.complete(arg, line)
      local res = vim.api.nvim_parse_cmd(line, {})
      local argc = #res.args
      local first = false
      if argc == 0 then
        first = true
      end
      if argc == 1 and not line:match("%s$") then
        first = true
      end
      if first then
        local options = vim
          .iter(names)
          :filter(function(option)
            return vim.startswith(option, arg)
          end)
          :totable()
        return options
      elseif argc == 2 or (argc == 1 and line:match("%s$")) then
        local argval = vim.trim(res.args[1])
        if subcommands[argval] and subcommands[argval].complete then
          return subcommands[argval].complete(arg, line)
        end
      end
    end

    local execute = function(args)
      args = args.fargs
      local cmd = args[1]
      local function wrap(f, ...)
        local ok, e = pcall(f, ...)
        if not ok then
          vim.notify(e, vim.log.levels.WARN)
        end
      end
      if not cmd then
        if command then
          if type(command) == "function" then
            wrap(command, args)
          else
            vim.api.nvim_exec2(command, { output = false })
          end
        else
          vim.notify("No subcommand specified", vim.log.levels.WARN)
        end
      elseif subcommands[cmd] then
        if type(subcommands[cmd].execute) == "function" then
          wrap(subcommands[cmd].execute, unpack(args, 2))
        elseif type(subcommands[cmd].execute) == "string" then
          ---@diagnostic disable-next-line: param-type-mismatch
          vim.api.nvim_exec2(subcommands[cmd].execute, {})
        end
      else
        vim.notify("Unknown subcommand " .. cmd, vim.log.levels.WARN)
      end
    end

    vim.api.nvim_create_user_command(name, execute, opts)
    return
  end
  vim.api.nvim_create_user_command(name, command, opts)
end

return M
