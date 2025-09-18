local function sleep(ms)
  local co = coroutine.running()
  vim.defer_fn(function()
    coroutine.resume(co)
  end, ms or 1000)
  coroutine.yield()
end

local function await(...)
  return coroutine.yield()
end

local function read_file(path)
  local co = coroutine.running()
  local function resume(...)
    return select(2, coroutine.resume(co, ...))
  end

  vim.uv.fs_open(path, "r", assert(tonumber(644, 8)), resume)
  local err, fd = coroutine.yield()
  if err or not fd then
    return
  end

  vim.uv.fs_read(fd, 100000, 0, resume)
  local err, str = coroutine.yield()

  local close_err = await(vim.uv.fs_close(fd, resume))
  if close_err then
    return
  end

  return err, str
end

local function run()
  coroutine.wrap(function()
    sleep(1000)
    vim.print("hi")
    local ok, text = read_file("init.lua")
    vim.print("done")
    vim.print(text)
  end)()
end

run()
