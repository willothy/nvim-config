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
M.system = M.wrap(vim.system)

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

return M
