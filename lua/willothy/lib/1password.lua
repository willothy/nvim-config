local CLI_NAME = "op"

local M = {}

function M.read(key, callback)
  vim.system({
    CLI_NAME,
    "read",
    key,
  }, {
    text = true,
  }, function(obj)
    if obj.code ~= 0 then
      callback(nil, obj.stderr)
      return
    end
    callback(obj.stdout, nil)
  end)
end

function M.read_sync(key)
  local obj = vim
    .system({
      CLI_NAME,
      "read",
      key,
    }, {
      text = true,
    })
    :wait()

  if obj.code ~= 0 then
    return nil, obj.stderr
  end
  return obj.stdout, nil
end

return M
