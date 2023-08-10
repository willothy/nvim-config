local M = {}

local function _telescope(_, picker)
  return function(...)
    local t = require("telescope")
    local ext = t.extensions
    if ext.menufacture[picker] ~= nil then
      ext.menufacture[picker](...)
    elseif require("telescope.builtin")[picker] then
      require("telescope.builtin")[picker](...)
    elseif ext[picker] then
      ext[picker][picker](...)
    else
      vim.notify(string.format("unknown picker %s", picker))
    end
  end
end

M.telescope = setmetatable({}, {
  __call = _telescope,
  __index = _telescope,
})

return M
