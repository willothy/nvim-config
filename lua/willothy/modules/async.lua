local yield = coroutine.yield
local resume = coroutine.resume
local running = coroutine.running
local create = coroutine.create

--- Create a callback function that resumes the current or specified coroutine when called.
--- @param co thread? The thread to resume, defaults to the running one.
local function callback(co)
  co = co or running()
  return function(...)
    resume(co, ...)
  end
end

--- Create an async function that can be called from a synchronous context.
--- Cannot return values as it is non-blocking.
--- @param fn fun(...)
--- @return fun(...)
local function void(fn)
  return function(...)
    resume(create(fn), ...)
  end
end

--- Run a function asynchronously and call the callback with the result.
--- @param fn fun(...):...:any
--- @param cb fun(...)
local function run(fn, cb, ...)
  local args = { ... }
  local task = create(function()
    cb(fn(unpack(args)))
  end)
  resume(task)
end

--- Wrap a callback-style function to be async.
--- @param fn fun(...):...
--- @param argc integer
--- @return async fun(...):...
local function wrap(fn, argc)
  return function(...)
    local args = { ... }
    args[argc] = callback()
    return yield(fn(unpack(args)))
  end
end

--- Yields to the Neovim scheduler
--- @async
local function schedule()
  return yield(vim.schedule(callback()))
end

--- Yields the current task, resuming when the specified timeout has elapsed.
--- @async
--- @param timeout integer
local function defer(timeout)
  yield(vim.defer_fn(callback(), timeout))
end

--- Async vim.system
--- @type async fun(cmd: string[], opts: table): vim.SystemCompleted
local system = wrap(vim.system, 3)

--- Async vim.uv wrapper
local uv = {}

--- @type async fun(path: string, entries: integer): string?, luv_dir_t
uv.fs_opendir = function(path, entries)
  ---@diagnostic disable-next-line: param-type-mismatch
  return yield(vim.uv.fs_opendir(path, callback(), entries))
end

--- @type async fun(dir: luv_dir_t): string?, uv.aliases.fs_readdir_entries[]
uv.fs_readdir = wrap(vim.uv.fs_readdir, 2)

-- run(function()
--   -- schedule()           -- wait until the nvim api is safe to call
--   -- system({ "ls" }, {}) -- run a command and yield until it's done
--   -- defer(2000)          -- wait 2 seconds and then resume the task
--
--   local err, dir
--   local entries = {}
--   err, dir = uv.fs_opendir(vim.fn.getcwd() or vim.uv.cwd() or vim.env.PWD, 5)
--   if err then
--     return "could not open dir"
--   end
--   local current
--   repeat
--     err, current = uv.fs_readdir(dir)
--     if current then
--       for _, entry in ipairs(current) do
--         table.insert(entries, entry)
--       end
--     end
--   until err or not current
--   if err then
--     return "could not read dir"
--   end
--   return entries
-- end, function(x)
--   if type(x) == "table" then
--     vim.notify(vim.inspect(x))
--   elseif x then
--     vim.notify(x)
--   end
-- end)

return {
  callback = callback,
  void = void,
  run = run,
  wrap = wrap,
  schedule = schedule,
  defer = defer,
  system = system,
  uv = uv,
}
