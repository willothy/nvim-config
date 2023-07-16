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
  for _ = 1, self.tasks do
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
