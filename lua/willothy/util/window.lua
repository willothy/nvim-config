local M = {}

function M.pick_focus()
  local win = require("window-picker").pick_or_create({
    filter_rules = {
      bo = {
        buftype = {},
      },
      include_current_win = false,
    },
  })
  if not win then return end
  vim.api.nvim_set_current_win(win)
end

function M.pick_swap()
  local win = require("window-picker").pick_window({
    filter_rules = {
      autoselect_one = false,
      bo = {
        buftype = {
          "nofile",
          "nowrite",
          "prompt",
        },
      },
    },
  })
  if not win then return end
  local curwin = vim.api.nvim_get_current_win()
  if
    require("stickybuf").is_pinned(win)
    or require("stickybuf").is_pinned(curwin)
  then
    -- hack to fix window dimming
    vim.api.nvim_set_current_win(curwin)
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local curbuf = vim.api.nvim_get_current_buf()
  if buf == curbuf or win == curwin then return end

  vim.api.nvim_win_set_buf(win, curbuf)
  vim.api.nvim_win_set_buf(curwin, buf)
end

function M.pick_close()
  local win = require("window-picker").pick_window({
    filter_rules = {
      include_current_win = true,
      autoselect_one = false,
    },
  })
  if not win then return end
  local ok, res = pcall(vim.api.nvim_win_close, win, false)
  if not ok then
    if vim.startswith(res, "Vim:E444") then
      vim.ui.select({ "Close", "Cancel" }, {
        prompt = "Close window?",
      }, function(i)
        if i == "Close" then vim.api.nvim_exec2("qa!", { output = true }) end
      end)
    else
      vim.notify("could not close window", vim.log.levels.WARN)
    end
  end
end

function M.split_right()
  local opt = vim.o.splitright
  vim.o.splitright = true
  vim.cmd("vsplit")
  vim.o.splitright = opt
end

function M.split_left()
  local opt = vim.o.splitright
  vim.o.splitright = false
  vim.cmd("vsplit")
  vim.o.splitright = opt
end

function M.split_below()
  local opt = vim.o.splitbelow
  vim.o.splitbelow = true
  vim.cmd("split")
  vim.o.splitbelow = opt
end

function M.split_above()
  local opt = vim.o.splitbelow
  vim.o.splitbelow = false
  vim.cmd("split")
  vim.o.splitbelow = opt
end

return M
