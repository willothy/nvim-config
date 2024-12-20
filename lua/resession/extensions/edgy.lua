-- NOTE: You cannot use upvalues in the functions used to open
-- windows, since they cannot be serialized.
--
-- Example edgy config:
-- ```lua
-- -- If you want to require a module, you must do it inside the function.
-- -- This will result in an error when loading, as `t` is an upvalue and
-- -- will not be valid when the function is loaded from session storage.
-- -- local t = require("toggleterm.terminal")
--
-- require("edgy").setup({
--   bottom = {
--     {
--       ft = "terminal",
--       open = function()
--         -- this is the correct way to require a module when
--         -- the function will be saved / restored.
--         local t = require("toggleterm.terminal")
--         local term = t.get_or_create_term(0)
--         if not term:is_open() then
--           term:open()
--         end
--       end,
--     },
--   },
-- })
-- ```
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
  local wins = {}

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    local info = save_win(win)
    if info then
      table.insert(wins, info)
    end
  end

  return wins
end

local function save_all()
  local wins = {}

  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    vim.list_extend(wins, save_tab(tab))
  end

  return wins
end

local function modify_opts()
  local curwin = vim.api.nvim_get_current_win()
  local splitkeep = vim.o.splitkeep
  local animate = require("edgy.config").animate.enabled

  vim.o.splitkeep = "topline"
  require("edgy.config").animate.enabled = false

  return vim.schedule_wrap(function()
    -- ensure "main" windows don't jump if edgy windows flicker
    vim.o.splitkeep = splitkeep
    -- disable edgy animation while opening windows (TODO: does this work?)
    require("edgy.config").animate.enabled = animate
    -- restore the original window
    vim.api.nvim_set_current_win(curwin)
  end)
end

function M.on_save(opts)
  if opts.tabpage then
    return {
      scope = "tabpage",
      wins = save_tab(opts.tabpage),
    }
  else
    return {
      scope = "global",
      wins = save_all(),
    }
  end
end

local first_tab

function M.on_pre_load()
  first_tab = #vim.api.nvim_list_tabpages() - 1
end

function M.on_post_load(data)
  local restore_opts
  -- call with the tabpage as the current tabpage
  local tabs = vim.api.nvim_list_tabpages()
  for _, win_info in ipairs(data.wins or {}) do
    local f = loadstring(win_info.open)
    if
      f and (data.scope == "tabpage" or tabs[win_info.tabpage + first_tab])
    then
      if not restore_opts then
        restore_opts = modify_opts()
      end
      local tab
      if data.scope == "global" then
        tab = tabs[win_info.tabpage + first_tab]
      else
        tab = 0
      end
      vim.api.nvim_win_call(vim.api.nvim_tabpage_get_win(tab), function()
        if not pcall(f) then
          vim.schedule(function()
            vim.notify(
              "[resession] Failed to open " .. win_info.ft,
              vim.log.levels.WARN
            )
          end)
        end
      end)
    end
  end
  if restore_opts then
    restore_opts()
  end
end

return M
