local M = {}

function M.switch_by_step(dir)
  local step = vim.v.count
  if step == 0 then step = 1 end
  step = step * dir

  local current_tab = vim.api.nvim_get_current_tabpage()
  local all_tabs = vim.api.nvim_list_tabpages()

  local next
  for i, tab in ipairs(all_tabs) do
    if tab == current_tab then
      next = all_tabs[(i + step - 1) % #all_tabs + 1]
    end
  end

  if next then vim.api.nvim_set_current_tabpage(next) end
end

return M
