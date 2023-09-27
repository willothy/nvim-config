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

--- @type async fun(path: string, entries: integer): err: string?, dir: luv_dir_t
uv.fs_opendir = function(path, entries)
  ---@diagnostic disable-next-line: param-type-mismatch
  return yield(vim.uv.fs_opendir(path, callback(), entries))
end

--- @type async fun(dir: luv_dir_t): err: string?, entries: uv.aliases.fs_readdir_entries[]
uv.fs_readdir = wrap(vim.uv.fs_readdir, 2)

--- @type async fun(path: string): err: string?, path: string?
uv.fs_realpath = wrap(vim.uv.fs_realpath, 2)

--- @type async fun(path: string): err: string?, path: string?
uv.fs_readlink = wrap(vim.uv.fs_readlink, 2)

--- @type async fun(path: string, mode: integer): err: string?, permissions: boolean?
uv.fs_access = wrap(vim.uv.fs_access, 3)

--- @type async fun(fd: integer, size: integer, offset: integer?): err: string?, data: string?
uv.fs_read = wrap(vim.uv.fs_read, 4)

--- @type async fun(path: string, new_path: string): err: string?, success: boolean?
uv.fs_rename = wrap(vim.uv.fs_rename, 2)

--- @type async fun(path: string, flags: integer | uv.aliases.fs_access_flags, mode: integer): err: string?, fs: integer?
uv.fs_open = wrap(vim.uv.fs_open, 4)

--- @type async fun(template: string): err: string?, fd: integer?, path: string?
uv.fs_mkstemp = wrap(vim.uv.fs_mkstemp, 2)

--- @type async fun(template: string): err: string?, path: string?
uv.fs_mkdtemp = wrap(vim.uv.fs_mkdtemp, 2)

--- @type async fun(path: string): err: string?, success: boolean?
uv.fs_rmdir = wrap(vim.uv.fs_rmdir, 2)

--- @type async fun(path: string, mode: integer): err: string?, success: boolean?
uv.fs_mkdir = wrap(vim.uv.fs_mkdir, 3)

--- @type async fun(path: string, mode: integer): err: string?, success: boolean?
uv.fs_chmod = wrap(vim.uv.fs_chmod, 3)

--- @type async fun(fd: integer, atime: integer, mtime: integer): err: string?, success: boolean?
uv.fs_futime = wrap(vim.uv.fs_futime, 4)

--- @type async fun(fd: integer, offset: integer): err: string?, success: boolean?
uv.fs_ftruncate = wrap(vim.uv.fs_ftruncate, 3)

--- @type async fun(path: string, new_path: string): err: string?, success: boolean?
uv.fs_link = wrap(vim.uv.fs_link, 3)

--- @type async fun(path: string): err: string?, success: boolean?
uv.fs_unlink = wrap(vim.uv.fs_unlink, 2)

--- @type async fun(fd: integer, data: string | string[], offset: integer?): err: string?, success: boolean?
uv.fs_write = wrap(vim.uv.fs_write, 4)

--- @type async fun(path: string, newpath: string, flags: integer | uv.aliases.fs_symlink_flags): err: string?, success: boolean?
uv.fs_symlink = wrap(vim.uv.fs_symlink, 3)

--- @type async fun(path: string, atime: integer, mtime: integer): err: string?, success: boolean?
uv.fs_lutime = wrap(vim.uv.fs_lutime, 4)

--- @type async fun(path: string): err: string?, stat: uv.aliases.fs_stat_table
uv.fs_stat = wrap(vim.uv.fs_stat, 2)

--- @type async fun(path: string): err: string?, stat: uv_fs_t?
uv.fs_scandir = wrap(vim.uv.fs_scandir, 2)

--- @type async fun(path: string): err: string?, stat: uv.aliases.fs_statfs_stats
uv.fs_statfs = wrap(vim.uv.fs_statfs, 2)

--- @type async fun(fd: integer): err: string?, success: boolean?
uv.fs_fsync = wrap(vim.uv.fs_fsync, 2)

--- @type async fun(out_fd: integer, in_fd: integer, in_offset: integer, size: integer): err: string?, bytes: integer?
uv.fs_sendfile = wrap(vim.uv.fs_sendfile, 4)

--- @type async fun(fd: integer): err: string?, success: boolean?
uv.fs_fdatasync = wrap(vim.uv.fs_fdatasync, 2)

--- @type async fun(fd: integer): err: string?, success: boolean?
uv.fs_close = wrap(vim.uv.fs_close, 2)

--- @type async fun(path: string, atime: integer, mtime: integer): err: string?, success: boolean?
uv.fs_utime = wrap(vim.uv.fs_utime, 4)

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
