local M = {}

function M.on_save()
  return vim
    .iter(vim.api.nvim_tabpage_list_wins(0))
    :map(function(win)
      return require("edgy").get_win(win)
    end)
    ---@param win Edgy.Window
    :filter(function(win)
      return win.view.open ~= nil
    end)
    ---@param win Edgy.Window
    :map(function(win)
      local open = win.view.open
      if type(open) == "string" then
        open = function()
          vim.api.nvim_exec2(open, { output = false })
        end
      end
      open = string.dump(open --[[@as fun()]])
      return {
        ft = win.view.ft,
        open = open,
      }
    end)
    :totable()
end

function M.on_pre_load(data)
  local win = vim.api.nvim_get_current_win()
  local animate = require("edgy.config").animate.enabled
  require("edgy.config").animate.enabled = false
  vim.iter(data or {}):each(function(wininfo)
    local f = loadstring(wininfo.open)
    if f then
      local ok = pcall(f)
      if not ok then
        vim.notify("[recession] Failed to open " .. wininfo.ft)
      end
    end
  end)
  require("edgy.config").animate.enabled = animate
  vim.api.nvim_set_current_win(win)
end

return M
