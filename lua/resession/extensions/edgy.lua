local M = {}

function M.on_save()
  local wins = {}
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local win = require("edgy").get_win(winid)
    if win and win.view.open then
      local open = win.view.open
      if type(open) == "string" then
        open = function()
          vim.api.nvim_exec2(open, { output = false })
        end
      end
      open = string.dump(open --[[@as fun()]])
      table.insert(wins, {
        ft = win.view.ft,
        open = open,
      })
    end
  end
  return wins
end

function M.on_pre_load(data)
  local win = vim.api.nvim_get_current_win()
  local animate = require("edgy.config").animate.enabled
  require("edgy.config").animate.enabled = false
  for _, wininfo in ipairs(data or {}) do
    local f = loadstring(wininfo.open)
    if f then
      local ok = pcall(f)
      if not ok then
        vim.notify("[resession] Failed to open " .. wininfo.ft, "warn")
      end
    end
  end
  require("edgy.config").animate.enabled = animate
  vim.api.nvim_set_current_win(win)
end

return M
