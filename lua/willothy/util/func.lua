local M = {}

function M.bind(func, ...)
  local args = ...
  return function(...)
    func(args, ...)
  end
end

return M
