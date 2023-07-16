local bit = require("bit")

local M = {}

---@param rgb number
---Converts an rgb number into a hex string
function M.hex(rgb)
  local r = bit.rshift(bit.band(rgb, 0xff0000), 16)
  local g = bit.rshift(bit.band(rgb, 0x00ff00), 8)
  local b = bit.band(rgb, 0x0000ff)

  return ("#%02x%02x%02x"):format(r, g, b)
end

---Alias to `vim.api.nvim_get_hl_id_by_name`
M.hl_id = vim.api.nvim_get_hl_id_by_name

---Alias to `vim.api.nvim_get_hl_by_id`
M.hl_by_id = vim.api.nvim_get_hl

local sanitize = {
  foreground = "fg",
  background = "bg",
  guifg = "fg",
  guibg = "bg",
  bold = "bold",
  underline = "underline",
  undercurl = "undercurl",
  italic = "italic",
  fg = "fg",
  bg = "bg",
  gui = function(self, gui)
    for _, g in ipairs({
      "bold",
      "italic",
      "underline",
      "undercurl",
      "strikethrough",
    }) do
      if gui:find(g) then self[g] = true end
    end
    self.gui = nil
  end,
  style = function(self, style)
    for _, s in ipairs({
      "bold",
      "italic",
      "underline",
      "undercurl",
      "strikethrough",
    }) do
      if style:find(s) then self[s] = true end
    end
    self.style = nil
  end,
}

---@param hl table
function M.sanitize(hl)
  for k, v in pairs(hl) do
    if type(v) == "number" then hl[k] = M.hex(v) end
    if sanitize[k] then
      if type(sanitize[k]) == "string" then
        hl[sanitize[k]] = hl[k]
      elseif type(sanitize[k]) == "function" then
        sanitize[k](hl, v)
      end
    else
      hl[k] = nil
    end
  end
  return hl
end

---@param group string | integer
function M.hl(group)
  return M.hl_by_id(
    0,
    type(group) == "number" and { id = group } or { name = group }
  )
end

-- local test_hl = {
--   bold = true,
--   italic = true,
--   underline = true,
--   undercurl = true,
--   strikethrough = true,
--   fg = 0xff0000,
--   bg = "0xf0faff",
-- }
--
-- print(M.sanitize(test_hl))
--
-- local test_hl_gui = {
--   gui = "bold,italic,underline,undercurl,strikethrough",
--   fg = 0xff0000,
--   bg = 0x00ffff,
-- }
-- print(M.sanitize(test_hl_gui))

---@class Task
---@field job thread
---@field done boolean
---@field ok boolean
---@field result any
---@field age integer
local Task = {}
Task.__index = Task

function Task:poll()
  if self.job then
    local ok, result = coroutine.resume(self.job)
    self.age = self.age + 1
    if not ok then
      self.done = true
      self.ok = false
      self.result = result
    elseif coroutine.status(self.job) == "dead" then
      self.done = true
      self.ok = true
      self.result = result
    end
  end
end

---@param func fun(...any)
---@return Task
function Task:new(func)
  local o = {
    done = false,
    ok = true,
    result = nil,
    age = 0,
    func = func,
  }
  local env = setmetatable({
    error = function(e)
      o.ok = false
      o.done = true
      o.result = e
    end,
  }, { __index = _G })
  setfenv(func, env)
  o.job = coroutine.create(func)
  setmetatable(o, Task)
  return o
end

function Task:wait()
  while not self.done do
    self:poll()
  end
  return self.ok, self.result
end

---@class Executor
---@field queue Task[]       # The task queue
---@field active Task        # The currently running task
---@field thread uv_thread_t # Background thread
---@field ticks integer      # Number of ticks since init
---@field tasks integer      # Number of running tasks
local Executor = {}
Executor.__index = Executor

---@return Executor
function Executor:new()
  local o = { queue = {}, ticks = 0, tasks = 0, active = nil }
  -- o.thread = vim.loop.new_thread()
  setmetatable(o, Executor)
  return o
end

---@param ... Task
---@return Task[]
function Executor:spawn(...)
  local n = select("#", ...)
  local tasks = {}
  for i = 1, n do
    local task = select(i, ...)
    table.insert(self.queue, task)
    table.insert(tasks, task)
    if self.active == nil then self.active = self.queue[#self.queue] end
    self.tasks = self.tasks + 1
  end
  return tasks
end

function Executor:spawn_group(tasks)
  -- just a convenience wrapper method
  self.spawn(unpack(tasks))
end

---@return Task | nil       # The task that was just completed, if any
function Executor:tick()
  self.ticks = self.ticks + 1
  if self.active then self.active:poll() end
  local prev = table.remove(self.queue, 1)
  if #self.queue > 0 then
    self.active = self.queue[1]
    if prev ~= nil and prev.ok == true and prev.done == false then
      table.insert(self.queue, prev)
    end
  end
  if prev and prev.done then
    self.tasks = self.tasks - 1
    return prev
  end
end

function Executor:cycle()
  for i = 1, self.tasks do
    self:tick()
  end
end

function Executor:all()
  local limit = 10000
  local current = 0
  while self.tasks > 0 do
    current = current + 1
    local env = getfenv(self.active.func)
    vim.print(env.error)
    env.error("test")
    if current > limit then
      env.error("Executor:all() hit limit of " .. limit .. " cycles")
    end
    self:cycle()
  end
end

function Executor:any()
  while self.tasks > 0 do
    local done = self:tick()
    if done then return done end
  end
end

local executor = Executor:new()

local t1 = Task:new(function()
  for _ = 1, 5 do
    -- while true do
    print("test")
    coroutine.yield()
  end
end)

local t2 = Task:new(function()
  local i = 1
  while i < 2 do
    print("test2")
    i = i + 1
    coroutine.yield()
  end
  return "yay!"
end)

t1, t2 = unpack(executor:spawn(t1, t2))

executor:any()

-- vim.print(t1)
-- vim.print(t2)
--
-- executor:tick()
-- executor:tick()
-- t2:wait()
-- executor:tick()
-- executor:tick()
-- executor:cycle()
-- executor:cycle()
-- t2:wait()
-- t1:wait()
