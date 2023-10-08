local M = {}

---@param winid integer
local function save_win(winid)
  local win = require("edgy").get_win(winid)
  if win and win.view.open then
    local open = win.view.open
    if type(open) == "string" then
      open = function()
        vim.api.nvim_exec2(open, { output = false })
      end
    end
    return {
      ft = win.view.ft,
      open = string.dump(open --[[@as fun()]]),
      -- save tabs by index and not id, since IDs may be different when the session is restored
      tabpage = vim.api.nvim_tabpage_get_number(
        vim.api.nvim_win_get_tabpage(winid)
      ),
    }
  end
end

---@param tabpage integer
local function save_tab(tabpage)
  return vim
    .iter(vim.api.nvim_tabpage_list_wins(tabpage))
    :map(save_win)
    :fold({}, function(acc, win_info)
      if win_info then
        table.insert(acc, win_info)
      end
      return acc
    end)
end

local function save_all()
  return vim
    .iter(vim.api.nvim_list_tabpages())
    :map(save_tab)
    :fold({}, function(acc, tab_info)
      if tab_info then
        vim.list_extend(acc, tab_info)
      end
      return acc
    end)
end

local function modify_opts()
  local curwin = vim.api.nvim_get_current_win()
  local splitkeep = vim.o.splitkeep
  local animate = require("edgy.config").animate.enabled

  vim.o.splitkeep = "topline"
  require("edgy.config").animate.enabled = false

  return function()
    -- ensure "main" windows don't jump if edgy windows flicker
    vim.o.splitkeep = splitkeep
    -- disable edgy animation while opening windows (TODO: does this work?)
    require("edgy.config").animate.enabled = animate
    -- restore the original window
    vim.api.nvim_set_current_win(curwin)
  end
end

function M.on_save(opts)
  if opts.tabpage then
    return save_tab(opts.tabpage)
  else
    return save_all()
  end
end

function M.on_pre_load(data)
  local restore_opts = modify_opts()
  -- call with the tabpage as the current tabpage
  local tabs = vim.api.nvim_list_tabpages()
  for _, win_info in ipairs(data) do
    local f = loadstring(win_info.open)
    if f and tabs[win_info.tabpage] then
      vim.api.nvim_win_call(
        vim.api.nvim_tabpage_get_win(tabs[win_info.tabpage]),
        function()
          if not pcall(f) then
            vim.notify(
              "[resession] Failed to open " .. win_info.ft,
              vim.log.levels.WARN
            )
          end
        end
      )
    end
  end
  restore_opts()
end

return M
