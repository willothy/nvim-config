local M = {}

local handles = setmetatable({}, { __mode = "k" })

function M.running()
  local current = coroutine.running()
  if current and handles[current] then
    return true
  end
end

function M.run(func, callback, ...)
  local co = coroutine.create(func)
  handles[co] = true

  local function step(...)
    local ret = { coroutine.resume(co, ...) }
    local stat = ret[1]

    if not stat then
      local err = ret[2] --[[@as string]]
      error(
        string.format(
          "The coroutine failed with this message: %s\n%s",
          err,
          debug.traceback(co)
        )
      )
    end

    if coroutine.status(co) == "dead" then
      if callback then
        callback(unpack(ret))
      end
      return
    end

    local fn = ret[2]

    ---@type any[]
    local args = { unpack(ret, 3) }
    args[#args + 1] = step

    fn(unpack(args))
  end

  step(...)
end

function M.wait(func, ...)
  local argc = select("#", ...) + 1

  local function pfunc(...)
    local args = { ... }
    local cb = args[argc]
    args[argc] = function(...)
      cb(true, ...)
    end
    xpcall(func, function(err)
      cb(false, err, debug.traceback())
    end, unpack(args, 1, argc))
  end

  local ret = { coroutine.yield(pfunc, ...) }

  local ok = ret[1]
  if not ok then
    local _, err, traceback = unpack(ret)
    error(string.format("Wrapped function failed: %s\n%s", err, traceback))
  end

  return ok, unpack(ret, 3, table.maxn(ret))
end

---@return fun(...):any
function M.wrap(func)
  return function(...)
    if not M.running() then
      func(...)
    end
    return M.wait(func, ...)
  end
end

function M.void(func)
  return function(...)
    if M.running() then
      return func(...)
    end
    return M.run(func, nil, ...)
  end
end

---@type fun(cmd: string[], opts: table): vim.SystemCompleted
M.system = M.wrap(function(cmd, opts, cb)
  vim.system(cmd, opts, cb)
end)

M.uv = {}

---@type fun(path: string, entries: integer): boolean, luv_dir_t
M.uv.fs_opendir = M.wrap(function(path, entries, cb)
  return vim.uv.fs_opendir(path, cb, entries)
end)

---@type fun(dir: luv_dir_t): boolean, uv.aliases.fs_readdir_entries[]
M.uv.fs_readdir = M.wrap(vim.uv.fs_readdir)

-- local function scandir(directory)
--   local ok, dir = M.uv.fs_opendir(directory or vim.uv.cwd(), 10)
--
--   if not ok then
--     error(dir)
--   end
--
--   local res = {}
--
--   local entries
--   repeat
--     entries = select(2, M.uv.fs_readdir(dir))
--     if entries then
--       vim.iter(entries):each(function(entry)
--         table.insert(res, entry)
--       end)
--     end
--   until not entries
--
--   return res
-- end
--
-- M.run(scandir, function(ok, res)
--   vim.notify(vim.inspect(res))
-- end)

-- Experiment with EXTREMELY simple async:
--
-- local yield = coroutine.yield
-- local resume = coroutine.resume
-- local running = coroutine.running
-- local create = coroutine.create
--
-- --- Create a callback function that resumes the current or specified coroutine when called.
-- local callback = function(co)
--   co = co or running()
--   return function(...)
--     resume(co, ...)
--   end
-- end
--
-- --- Create an async function that can be called from a synchronous context.
-- --- Cannot return values as it is non-blocking.
-- local void = function(fn)
--   return function(...)
--     resume(create(fn), ...)
--   end
-- end
--
-- --- Async vim.system
-- local system = function(cmd, opts)
--   return yield(vim.system(cmd, opts, callback()))
-- end
--
-- local uv = {}
--
-- ---@async
-- ---@param path string
-- ---@param entries integer
-- ---@return luv_dir_t
-- uv.fs_opendir = function(path, entries)
--   ---@diagnostic disable-next-line: param-type-mismatch
--   return select(2, yield(vim.uv.fs_opendir(path, callback(), entries)))
-- end
--
-- ---@async
-- ---@param dir luv_dir_t
-- ---@return uv.aliases.fs_readdir_entries[]
-- uv.fs_readdir = function(dir)
--   return select(2, yield(vim.uv.fs_readdir(dir, callback())))
-- end
--
-- ---@async
-- ---@param directory string
-- ---@return uv.aliases.fs_readdir_entries[]
-- local function scandir(directory)
--   local dir = uv.fs_opendir(directory or vim.uv.cwd(), 10)
--
--   local res = {}
--
--   local entries
--   repeat
--     entries = uv.fs_readdir(dir)
--     vim.iter(entries or {}):each(function(entry)
--       table.insert(res, entry)
--     end)
--   until not entries
--
--   return res
-- end
--
-- --- Yields to the Neovim scheduler
-- local schedule = function()
--   return yield(vim.schedule(callback()))
-- end
--
-- local main = void(function()
--   -- schedule()
--   -- local output = system({ "ls" }, {})
--   -- vim.notify(output.stdout)
--   -- vim.notify(vim.inspect(scandir()))
-- end)
--
-- main()

return M
