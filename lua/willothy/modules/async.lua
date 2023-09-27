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
local function wrap(fn, argc)
  return function(...)
    local args = { ... }
    args[argc] = callback()
    return yield(fn(unpack(args)))
  end
end

--- Yields to the Neovim scheduler
local function schedule()
  return yield(vim.schedule(callback()))
end

--- Async vim.system
--- @type async fun(cmd: string[], opts: table): vim.SystemCompleted
local system = wrap(vim.system, 3)

--- Async vim.uv wrapper
local uv = {}

--- @type async fun(path: string, entries: integer): luv_dir_t
uv.fs_opendir = function(path, entries)
  ---@diagnostic disable-next-line: param-type-mismatch
  return select(2, yield(vim.uv.fs_opendir(path, callback(), entries)))
end

--- @type async fun(dir: luv_dir_t): uv.aliases.fs_readdir_entries[]
uv.fs_readdir = wrap(vim.uv.fs_readdir, 2)

-- run(function()
--   -- schedule()
--   -- local output = system({ "ls" }, {})
--   -- vim.notify(output.stdout)
--   return system({ "ls" }, {}).stdout
-- end, function(x)
--   if type(x) == "table" then
--     vim.notify(vim.inspect(x))
--   else
--     vim.notify(x)
--   end
-- end)

return {
  callback = callback,
  void = void,
  run = run,
  wrap = wrap,
  schedule = schedule,
  system = system,
  uv = uv,
}
