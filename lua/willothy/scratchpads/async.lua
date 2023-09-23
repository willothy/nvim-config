local M = {}

function M.run(func, callback, ...)
  local co = coroutine.create(func)

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

    --- @type integer, function
    local nargs, fn = ret[2], ret[3]

    assert(type(fn) == "function", "type error :: expected func")

    local args = { select(4, unpack(ret)) }
    args[nargs] = step

    fn(unpack(args, 1, nargs))
  end

  step(...)
end

function M.wait(argc, func, ...)
  local function pfunc(...)
    local args = { ... } --- @type any[]
    local cb = args[argc]
    args[argc] = function(...)
      cb(true, ...)
    end
    xpcall(func, function(err)
      cb(false, err, debug.traceback())
    end, unpack(args, 1, argc))
  end

  local ret = { coroutine.yield(argc, pfunc, ...) }

  local ok = ret[1]
  if not ok then
    local _, err, traceback = unpack(ret)
    error(string.format("Wrapped function failed: %s\n%s", err, traceback))
  end

  return ok, unpack(ret, 3, table.maxn(ret))
end

function M.wrap(func)
  return function(...)
    local argc = select("#", ...) + 1
    return M.wait(argc, func, ...)
  end
end

return M

-- local uv_open_dir = M.wrap(function(path, entries, cb)
--   ---@diagnostic disable-next-line: param-type-mismatch
--   return vim.uv.fs_opendir(path, cb, entries)
-- end)
--
-- local uv_read_dir = M.wrap(vim.uv.fs_readdir)

-- local function scandir(directory)
--   local ok, dir = uv_open_dir(directory or vim.uv.cwd(), 1)
--   local read = function()
--     return uv_read_dir(dir)
--   end
--
--   local res = {}
--
--   local entries
--   repeat
--     entries = select(2, read())
--     if entries then
--       vim.iter(entries):each(function(entry)
--         table.insert(res, entry)
--       end)
--     end
--   until not entries
--
--   return res
-- end

-- M.run(scandir, function(ok, res)
--   vim.notify(vim.inspect(res))
-- end)
