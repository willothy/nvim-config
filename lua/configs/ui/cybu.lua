require("cybu").setup({
  position = {
    relative_to = "editor",
    horizontal_offset = 0,
    vertical_offset = 0,
    max_win_height = 6,
  },
  behavior = {},
  display_time = 1000,
})

local au = vim.api.nvim_create_augroup("configs.ui.cybu", { clear = true })

local last

vim.api.nvim_create_autocmd("BufLeave", {
  group = au,
  callback = function(ev)
    if not vim.bo[ev.buf].buflisted then
      return
    end
    last = {
      win = vim.api.nvim_get_current_win(),
      buf = ev.buf,
    }
  end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = au,
  callback = function(ev)
    if last == nil then
      return
    end
    if
      last.win ~= vim.api.nvim_get_current_win()
      or not vim.bo[ev.buf].buflisted
      or vim.api.nvim_buf_get_name(ev.buf) == ""
    then
      last = nil
      return
    end
    require("cybu").autocmd()
    last = nil
  end,
})
