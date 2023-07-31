local M = {}

M.launchers = {
  lua = function()
    require("osv").run_this()
  end,
}

function M.launch()
  local filetype = vim.bo.filetype
  local launch = require("willothy.dap").launchers[filetype]
  if launch then
    local ok, res = pcall(launch)
    if not ok then
      vim.notify(
        ("Failed to start debugger for %s: %s"):format(filetype, res),
        "error"
      )
    end
  else
    vim.notify(("No debugger available for %s"):format(filetype), "warn")
  end
end

function M.is_active()
  return require("dap").session() ~= nil
end

return M
