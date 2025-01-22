-- Allows scrolloff to be applied when scrolling past the end of a file.
--
-- Hijacks wo:scrolloff, and sets it to min(scrolloff, winheight / 2)
-- to ensure that scroll is always consistent between windows of different sizes.
--
-- This will be updated with the window, and the original scrolloff value can be
-- found in `vim.wo[winid].original_scrolloff`.

local M = {}

local disabled = false

local disabled_ft = {
  terminal = true,
}
local last_win, last_line
local function check_eof_scrolloff()
  if disabled then
    return
  end
  local filetype = vim.api.nvim_get_option_value("filetype", {
    scope = "local",
  })
  local buftype = vim.api.nvim_get_option_value("buftype", {
    scope = "local",
  })
  if disabled_ft[filetype] or buftype ~= "" then
    return
  end

  local win = vim.api.nvim_get_current_win()
  local cursor_line = vim.api.nvim_win_get_cursor(win)[1]

  -- Don't do anything if we've only moved horizontally
  if
    last_win ~= nil
    and last_line ~= nil
    and last_win == win
    and last_line == cursor_line
  then
    return
  end

  local view = vim.fn.winsaveview()
  if not view then
    return
  end

  last_win = win
  last_line = cursor_line

  local win_cur_line = vim.fn.winline()
  local win_height = vim.fn.winheight(0)
  local scrolloff
  if vim.w[0].original_scrolloff then
    scrolloff = vim.w[0].original_scrolloff
  else
    scrolloff = vim.wo[0].scrolloff
  end
  scrolloff = math.min(scrolloff, math.floor(win_height / 2))
  if vim.wo[0].scrolloff ~= scrolloff then
    if vim.w[0].original_scrolloff == nil then
      vim.w[0].original_scrolloff = vim.wo[0].scrolloff
    end
    vim.wo[0].scrolloff = scrolloff
  end
  local visual_distance_to_eof = win_height - win_cur_line

  if visual_distance_to_eof < scrolloff then
    local goal = view.topline + scrolloff - visual_distance_to_eof
    view.topline = goal
    vim.fn.winrestview(view)
  elseif win_cur_line < scrolloff then
    local goal = view.topline - (scrolloff - win_cur_line)
    view.topline = goal
    vim.fn.winrestview(view)
  end
end

M.disable = function()
  disabled = true
end

M.enable = function()
  disabled = false
end

M.toggle = function()
  disabled = not disabled
end

M.setup = function()
  local scrollEOF_group =
    vim.api.nvim_create_augroup("ScrollEOF", { clear = true })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = scrollEOF_group,
    callback = function()
      check_eof_scrolloff()
    end,
  })

  check_eof_scrolloff()
end

M.check = check_eof_scrolloff

return M
