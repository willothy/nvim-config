local M = {}

function M.pick_focus()
  local win = require("window-picker").pick_window({
    filter_rules = {
      bo = {
        buftype = {},
      },
      include_current_win = false,
    },
  })
  if not win then
    return
  end
  vim.api.nvim_set_current_win(win)
end

function M.pick_create()
  local win = require("window-picker").pick_window({
    filter_rules = {
      bo = {
        buftype = {},
      },
      include_current_win = true,
      autoselect_one = true,
    },
    or_create = true,
  })
  if not win then
    return
  end
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
  if not win then
    return
  end
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
  if win == curwin then
    return
  end
  local cur_view = vim.api.nvim_win_call(curwin, vim.fn.winsaveview)
  local tgt_view = vim.api.nvim_win_call(win, vim.fn.winsaveview)
  if buf ~= curbuf then
    vim.api.nvim_win_set_buf(win, curbuf)
    vim.api.nvim_win_set_buf(curwin, buf)
  end
  vim.api.nvim_win_call(curwin, function()
    vim.fn.winrestview(tgt_view)
  end)
  vim.api.nvim_win_call(win, function()
    vim.fn.winrestview(cur_view)
  end)
end

function M.pick_close()
  local win = require("window-picker").pick_window({
    filter_rules = {
      include_current_win = true,
      autoselect_one = false,
    },
  })
  if not win then
    return
  end
  local ok, res = pcall(vim.api.nvim_win_close, win, false)
  if not ok then
    if vim.startswith(res, "Vim:E444") then
      vim.ui.select({ "Close", "Cancel" }, {
        prompt = "Close window?",
      }, function(i)
        if i == "Close" then
          vim.api.nvim_exec2("qa!", { output = true })
        end
      end)
    else
      vim.notify("could not close window", vim.log.levels.WARN)
    end
  end
end

function M.is_float(win)
  return vim.api.nvim_win_get_config(win).zindex ~= nil
end

function M.is_focusable(win)
  if M.is_float(win) then
    return vim.api.nvim_win_get_config(win).focusable
  end
  return true
end

function M.iter()
  return vim.iter(vim.api.nvim_list_wins())
end

function M.close(win)
  vim.api.nvim_win_close(win, true)
end

function M.is_last(win)
  local tabpage = vim.api.nvim_win_get_tabpage(win)
  local layout = vim.api.nvim_tabpage_get_layout(tabpage, win)
  return layout[1] == "leaf"
end

function M.close_floats()
  M.iter():filter(M.is_float):each(M.close)
end

function M.close_all()
  vim.api.nvim_tabpage_set_layout(
    0,
    { "leaf", vim.api.nvim_get_current_buf() }
  )
end

function M.select_float()
  local wins = M.iter()
    :filter(M.is_float)
    :filter(M.is_focusable)
    :map(function(win)
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      local name = vim.api.nvim_buf_get_name(buf)
      local exclude = {
        notify = true,
      }
      if ft == "" or exclude[ft] then
        return
      end
      return setmetatable({
        win = win,
        buf = buf,
        ft = ft,
        name = name,
      }, {
        __tostring = function(self)
          return ("%s: %s"):format(
            vim.fn.fnamemodify(
              self.name ~= "" and self.name or "unnamed",
              ":t"
            ),
            self.ft
          )
        end,
      })
    end)
    :totable()

  if #wins == 0 then
    vim.notify("No floating windows", "info")
    return
  end

  vim.ui.select(wins, {}, function(item)
    if vim.api.nvim_win_is_valid(item.win) then
      vim.api.nvim_set_current_win(item.win)
    else
      vim.notify("Window is no longer valid", "warn")
    end
  end)
end

function M.split_right()
  local opt = vim.o.splitright
  vim.o.splitright = true
  vim.cmd("vsplit")
  vim.o.splitright = opt
  return vim.api.nvim_get_current_win()
end

function M.split_left()
  local opt = vim.o.splitright
  vim.o.splitright = false
  vim.cmd("vsplit")
  vim.o.splitright = opt
  return vim.api.nvim_get_current_win()
end

function M.split_below()
  local opt = vim.o.splitbelow
  vim.o.splitbelow = true
  vim.cmd("split")
  vim.o.splitbelow = opt
  return vim.api.nvim_get_current_win()
end

function M.split_above()
  local opt = vim.o.splitbelow
  vim.o.splitbelow = false
  vim.cmd("split")
  vim.o.splitbelow = opt
  return vim.api.nvim_get_current_win()
end

function M.open(buf, config, enter)
  config = vim.tbl_deep_extend("force", {
    relative = "cursor",
    row = 1,
    col = 1,
    width = 40,
    height = 10,
    style = "minimal",
    border = "solid",
  }, config or {})
  buf = buf or vim.api.nvim_create_buf(false, true)

  return vim.api.nvim_open_win(buf, enter or false, config), buf
end

M.border = {}

M.border.solid = {
  { " ", "NoiceCmdlinePopupBorder" },
  { " ", "NoiceCmdlinePopupBorder" },
  { "▀", "NoiceCmdlinePopupBorder" },
  { "▀", "NoiceCmdlinePopupBorder" },
  { "▀", "NoiceCmdlinePopupBorder" },
  { "▄", "NoiceCmdlinePopupBorder" },
  { "▄", "NoiceCmdlinePopupBorder" },
  { "▄", "NoiceCmdlinePopupBorder" },
}

return M
