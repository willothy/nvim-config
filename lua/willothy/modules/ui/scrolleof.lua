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
      next_fold_end_ln = vim.fn.foldclosedend(ln)
      local is_folded_line = next_fold_end_ln ~= -1
      if is_folded_line then
        local fold_size = next_fold_end_ln - ln
        folded_lines = folded_lines + fold_size
      end
    end
  end

  return folded_lines
end

local function check_eof_scrolloff()
  if disabled then
    return
  end

  local win_height = vim.api.nvim_win_get_height(0)
  local last_line = vim.fn.line("$")
  local win_last_line = vim.fn.line("w$")

  -- PERF avoid calculations when far away from the end of file
  if win_last_line + win_height < last_line then
    return
  end

  local win_view = vim.fn.winsaveview()
  local scrolloff = math.min(vim.o.scrolloff, math.floor(win_height / 2))
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
    vim.fn.winrestview({
      topline = win_view.topline
        + scrolloff
        - (scrolloff_line_count + visual_distance_to_eof),
    })
  end
end

M.setup = function()
  local disabled_ft = {
    "terminal",
  }

  local scrollEOF_group =
    vim.api.nvim_create_augroup("ScrollEOF", { clear = true })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = scrollEOF_group,
    callback = function()
      disabled = disabled_ft[vim.bo.filetype] ~= nil or vim.bo.buftype ~= ""
    end,
  })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = scrollEOF_group,
    callback = check_eof_scrolloff,
  })
end

return M
