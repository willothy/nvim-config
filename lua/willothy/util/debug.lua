local M = {}

function M.func_info(func)
  local info = debug.getinfo(func)
  local ret = {}
  for k, v in pairs(info) do
    if type(v) == "table" then
      ret[k] = vim.inspect(v)
    else
      ret[k] = v
    end
  end
  return ret
end

function M.upvalues(f, dbg)
  local ret = {}

  local i = 1
  while true do
    local name, value = debug.getupvalue(f, i)
    if not name then break end
    if dbg and type(value) == "function" then
      table.insert(ret, i, { name, M.func_info(value) })
    else
      table.insert(ret, i, { name, value })
    end
    i = i + 1
  end

  return ret
end

function M.reload(mod)
  package.loaded[mod] = nil
  return require(mod)
end

function M.current_mod()
  return string.gsub(
    vim.fn.expand("%:p:r:s?" .. vim.fn.stdpath("config") .. "/lua/??"),
    string.sub(package["config"], 1, 1),
    "."
  )
end

function M.pipe(data, ...)
  if type(data) == "function" then
    data = data(...)
  elseif type(data) == "table" then
    data = vim.inspect(data)
  elseif type(data) ~= "string" then
    data = tostring(data)
  else
    data = vim.api.nvim_exec2(data, {
      output = true,
    }).output
  end
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()

  local cursor = vim.api.nvim_win_get_cursor(win)

  local lines = vim.split(data or "", "\n", true)
  if #lines > 0 and lines[1] ~= "" then
    vim.api.nvim_buf_set_lines(buf, cursor[1], cursor[1], false, lines)
  end
end

return M
