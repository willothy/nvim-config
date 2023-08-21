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
    last = vim.api.nvim_get_current_win()
  end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = au,
  callback = function()
    if last == vim.api.nvim_get_current_win() then
      require("cybu").autocmd()
    end
    last = nil
  end,
})
