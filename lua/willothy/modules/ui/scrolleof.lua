-- adapted from https://github.com/Aasim-A/scrollEOF/nvim

local M = {}

local disabled = false

---Counts the number of folded lines between two line numbers
---@param lnum1 number
---@param lnum2 number
---@return number
local function folded_lines_between(lnum1, lnum2)
  local next_fold_end_ln = -1
  local folded_lines = 0

  for ln = lnum1, lnum2, 1 do
    if ln > next_fold_end_ln then -- skip folded lines we already added to the count
      next_fold_end_ln = vim.fn.foldclosedend(ln) or -1
      local is_folded_line = next_fold_end_ln ~= -1
      if is_folded_line then
        local fold_size = next_fold_end_ln - ln
        folded_lines = folded_lines + fold_size
      end
    end
  end

  return folded_lines
end

local cancel
local disabled_ft = {
  terminal = true,
}
local function check_eof_scrolloff(animate)
  if cancel then
    cancel()
    cancel = nil
  end
  if disabled then
    return
  end
  if disabled_ft[vim.bo.filetype] or vim.bo.buftype ~= "" then
    return
  end

  local win = vim.api.nvim_get_current_win()
  local win_view = vim.fn.winsaveview()
  local win_height = vim.api.nvim_win_get_height(win)
  local last_line = vim.fn.line("$")
  local win_last_line = vim.fn.line("w$")

  if not win_view or not last_line or not win_last_line then
    return
  end

  local scrolloff = vim.o.scrolloff
  local cur_line = win_view.lnum
  local win_top_line = win_view.topline
  local visual_distance_to_eof = last_line
    - cur_line
    - folded_lines_between(cur_line, last_line)
  local visual_last_line_in_win = win_last_line
    - folded_lines_between(win_top_line, win_last_line)
  local scrolloff_line_count = win_height
    - (visual_last_line_in_win - win_top_line + 1)

  if
    visual_distance_to_eof < scrolloff
    and scrolloff_line_count + visual_distance_to_eof < scrolloff
  then
    local goal = win_top_line
      + scrolloff
      - (scrolloff_line_count + visual_distance_to_eof)
    local diff = math.abs(goal - win_top_line)
    if animate then
      cancel = willothy.fn.animate(
        win_top_line,
        goal,
        vim.schedule_wrap(function(top)
          if win == vim.api.nvim_get_current_win() then
            vim.fn.winrestview({ topline = math.floor(top) })
          end
        end),
        {
          fps = 60,
          duration = diff * 30,
        }
      )
    else
      vim.fn.winrestview({ topline = goal })
    end
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

  check_eof_scrolloff(true)
end

M.check = check_eof_scrolloff

return M