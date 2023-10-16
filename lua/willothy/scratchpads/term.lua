local uv = vim.uv

local stdin = vim.uv.new_pipe() --[[@as uv_pipe_t]]
local stdout = vim.uv.new_pipe() --[[@as uv_pipe_t]]
local stderr = vim.uv.new_pipe() --[[@as uv_pipe_t]]

local buf = vim.api.nvim_create_buf(false, true)
vim.bo[buf].filetype = "terminal"
-- vim.bo[buf].buftype = "terminal"
local curwin = vim.api.nvim_get_current_win()
vim.cmd.split()
local win = vim.api.nvim_get_current_win()
vim.api.nvim_set_current_win(curwin)
vim.api.nvim_win_set_buf(win, buf)
-- local win = vim.api.nvim_open_win(buf, false, {
--   -- split = "below",
-- })

local chan = vim.api.nvim_open_term(buf, {
  on_input = function(_, _, _, data)
    stdin:write(data)
  end,
  -- pty = true,
})
-- local fd = vim.api.nvim_get_chan_info(chan).slave_fd

local handle = uv.spawn(
  "zsh",
  {
    args = { "-i" },
    stdio = { stdin, fd, fd },
  },
  vim.schedule_wrap(function()
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, { force = true })
  end)
)

-- stdout:read_start(vim.schedule_wrap(function(_, data)
--   if data then
--     vim.api.nvim_chan_send(chan, data)
--   end
-- end))
--
-- stderr:read_start(vim.schedule_wrap(function(_, data)
--   if data then
--     vim.api.nvim_chan_send(chan, data)
--   end
-- end))
