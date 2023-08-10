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

M.notify_mini = function(msg, opts)
  local title = opts.title
  local level = opts.level or vim.log.levels.INFO
  require("noice.message.router").redirect(function()
    vim.notify(msg, level, {
      title = title,
    })
  end, {
    { filter = {}, view = "mini" },
  })
end

M.redirect = function(view, msg, title)
  require("noice.message.router").redirect(function()
    vim.notify(msg, vim.log.levels.INFO, {
      title = title or "Notify",
    })
  end, {
    { filter = {}, view = view },
  })
end

M.popup = function(msg, title)
  M.redirect("popup", msg, title)
end

return M
