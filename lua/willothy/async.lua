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
    local status = coroutine.status(self.job)

    if coroutine.status(self.job) == "suspended" then
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
    elseif coroutine.status(self.job) == "dead" then
      self.done = true
      self.ok = true
    end
  end
end

---@param func fun(...: any)
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
    require = function(mod)
      mod = require(mod)
      if coroutine.isyieldable() then coroutine.yield() end
    end,
    ipairs = function(t)
      local i = 0
      return function()
        if coroutine.isyieldable() then coroutine.yield() end
        i = i + 1
        if t[i] then return i, t[i] end
      end
    end,
    pairs = function(t)
      local k, v
      return function()
        if coroutine.isyieldable() then coroutine.yield() end
        k, v = next(t, k)
        if k then return k, v end
      end
    end,
    exit = function(x)
      o.done = true
      if x and type(x) == "number" then
        o.ok = x == 0
      elseif x and type(x) == "boolean" then
        o.ok = x
      else
        o.ok = true
      end
    end,
  }, { __index = _G })
  setfenv(func, env)
  o.job = coroutine.create(func)
  setmetatable(o, Task)
  return o
end

---@class Executor
---@field queue Task[]       # The task queue
---@field cache table<integer, Task> # task lookup by id
---@field active Task        # The currently running task
---@field thread uv_thread_t # Background thread
---@field ticks integer      # Number of ticks since init
---@field tasks integer      # Number of running tasks
local Executor = {}
Executor.__index = Executor

---@return Executor
function Executor:new()
  local o = { queue = {}, ticks = 0, tasks = 0, active = nil }
  setmetatable(o, Executor)
  return o
end

---@return integer
function Executor:free_id()
  local id = (math.random(1, #queue) % #queue) + 1
  while self.cache[id] do
    id = id + 1
  end
  return id
end

---@param task Task | thread | fun() | string
---@param opts { args: string[]? } Spawn configuration
---@return Task
function Executor:spawn(task, opts)
  local id = self:free_id()
  local ty = type(task)
  if ty == "function" then
    task = Task:new(task)
  elseif ty == "string" then
    local cmd = task
    task = Task:new(function()
      local stdin = vim.loop.new_pipe()
      local stdout = vim.loop.new_pipe()
      local stderr = vim.loop.new_pipe()
      local opts = {
        args = opts.args or {},
        stdio = { stdin, stdout, stderr },
      }

      local done = false
      local handle, pid = vim.loop.spawn(cmd, opts, function(code, signal)
        done = true
        self.cache[id] = nil
      end)

      local out, err = "", ""

      vim.loop.read_start(stdout, function(e, data)
        if data then out = out .. data end
      end)
      vim.loop.read_start(stderr, function(e, data)
        if data then err = err .. data end
      end)

      while not done do
        coroutine.yield()
      end
      vim.print("done, " .. out)
      vim.loop.close(handle)
      return out, err
    end)
  end
  if task then
    table.insert(self.queue, task)
    if self.active == nil then self.active = self.queue[#self.queue] end
    self.tasks = self.tasks + 1
  end
  local function class()
  end

  return function()
    while not self.cache[id].done do
      coroutine.yield()
    end
    return task.result
  end
end

---@return Task | nil       # The task that was just completed, if any
function Executor:tick()
  self.ticks = self.ticks + 1
  local prev
  if self.active then
    self.active:poll()
    prev = self.active
  end
  if #self.queue > 0 then
    self.active = table.remove(self.queue, 1)
    if prev ~= nil and prev.done == false then
      table.insert(self.queue, prev)
    end
  else
    self.active = nil
  end
  if prev ~= nil and prev.done == true then
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

function Executor:init()
  self.ns = vim.api.nvim_create_namespace("willothy_async")
  vim.api.nvim_set_decoration_provider(self.ns, {
    on_end = function() self:tick() end,
  })
  return self
end

function Executor:shutdown()
  vim.api.nvim_set_decoration_provider(self.ns, {})
  vim.api.nvim_del_namespace(self.ns)
end

_G.executor = Executor:new():init()
_G.spawn = function(...) return _G.executor:spawn(...) end
_G.wrap = function(f, ...)
  local args = { ... }
  return function() return f(unpack(args)) end
end
