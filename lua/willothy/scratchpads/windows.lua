local M = {}

-- M.state = {}
-- M.enabled = true
-- M.layout = M
--
-- function M.enable()
--   if not M.enabled then
--     M.layout = M.layout_wins()
--     M.enabled = true
--   end
-- end
--
-- function M.is_enabled()
--   if M.enabled then
--     local layout = M.layout_wins()
--     if not vim.deep_equal(layout, M.layout) then M.enabled = false end
--   end
--   return M.enabled
-- end
--
-- -- Do a breadth-first search of the window
-- -- tree to gather a list of windows
-- function M.layout_wins()
--   local layout = vim.fn.winlayout()
--   local wins = {}
--
--   local queue = { layout }
--
--   while #queue > 0 do
--     local cur = table.remove(queue, 1)
--     if cur[1] == "leaf" then
--       table.insert(wins, cur[2])
--     else
--       for _, child in ipairs(cur[2]) do
--         table.insert(queue, child)
--       end
--     end
--   end
--
--   return wins
-- end
--
-- function M.save()
--   if not M.is_enabled() then return end
--   local wins = M.layout_wins()
--   vim.iter(wins):each(
--     function(win)
--       M.state[win] = M.state[win]
--         or vim.api.nvim_win_call(win, vim.fn.winsaveview)
--     end
--   )
-- end
--
-- function M.restore()
--   local wins = M.layout_wins()
--   vim.iter(wins):each(function(win)
--     if vim.api.nvim_win_is_valid(win) then
--       if M.state[win] then
--         vim.api.nvim_win_call(
--           win,
--           function() vim.fn.winrestview(M.state[win]) end
--         )
--       end
--     else
--       M.state[win] = nil
--     end
--   end)
--   M.enable()
-- end
--

local lib = require("winshift.lib")
local picker = require("window-picker")

function M.move_frame(target_win)
  local tree = lib.get_layout_tree()
  local curwin = vim.api.nvim_get_current_win()
  local leaf = lib.find_leaf(tree, curwin)
  local parent = leaf.parent
  if not parent then return end

  local target = lib.find_leaf(tree, target_win)

  local grandparent = parent.parent
  if grandparent then
    -- ??
    if grandparent.type == "row" then
      lib.row_move_in(target, grandparent, "left")
    else
      lib.col_move_in(target, grandparent, "up")
    end
  end

  if parent.type == "row" then
    lib.move_row(parent, target_win)
  else
    lib.move_col(parent, target_win)
  end
end

function M.pick_move()
  local win = picker.pick_or_create()
  if not win then return end
  M.move_frame(win)
end

return M
