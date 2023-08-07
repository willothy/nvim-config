local M = {}

function M.create_buf()
  if M.buf and vim.api.nvim_buf_is_valid(M.buf) then return end
  M.buf = vim.api.nvim_create_buf(false, true)
end

function M.create_win()
  M.create_buf()
  if M.win == nil or not vim.api.nvim_win_is_valid(M.win) then
    local config = {
      width = 30,
      height = 10,
      anchor = "NW",
      style = "minimal",
      border = "rounded",
      relative = "editor",
      noautocmd = true,
      focusable = false,
      zindex = 500,
    }
    config.row = vim.o.lines - config.height - 3
    config.col = vim.o.columns - config.width

    M.win = vim.api.nvim_open_win(M.buf, false, config)
  end
end

function M.close_win()
  if M.win then
    vim.api.nvim_win_close(M.win, true)
    M.win = nil
  end
end

local keys = {
  [vim.keycode("<Leader>")] = "<Leader>",
  [vim.keycode("<Esc>")] = "<Esc>",
  [vim.keycode("<Tab>")] = "<Tab>",
  [vim.keycode("<CR>")] = "<CR>",
  [vim.keycode("<BS>")] = "<BS>",
  [vim.keycode("<Space>")] = "<Space>",
  [vim.keycode("<Del>")] = "<Del>",
  [vim.keycode("<Up>")] = "<Up>",
  [vim.keycode("<Down>")] = "<Down>",
  [vim.keycode("<Left>")] = "<Left>",
  [vim.keycode("<Right>")] = "<Right>",
  [vim.keycode("<Home>")] = "<Home>",
  [vim.keycode("<End>")] = "<End>",
  [vim.keycode("<PageUp>")] = "<PageUp>",
  [vim.keycode("<PageDown>")] = "<PageDown>",
  [vim.keycode("<Insert>")] = "<Insert>",
  [vim.keycode("<F1>")] = "<F1>",
  [vim.keycode("<F2>")] = "<F2>",
  [vim.keycode("<F3>")] = "<F3>",
  [vim.keycode("<F4>")] = "<F4>",
  [vim.keycode("<F5>")] = "<F5>",
  [vim.keycode("<F6>")] = "<F6>",
  [vim.keycode("<F7>")] = "<F7>",
  [vim.keycode("<F8>")] = "<F8>",
  [vim.keycode("<F9>")] = "<F9>",
  [vim.keycode("<F10>")] = "<F10>",
  [vim.keycode("<F11>")] = "<F11>",
  [vim.keycode("<F12>")] = "<F12>",
}

for i = 33, 126 do
  keys[vim.keycode(string.char(i))] = string.char(i)
end

function M.set_title(title, append)
  local config = vim.api.nvim_win_get_config(M.win)
  local t = keys[title] or "" -- or title
  -- for i = 1, string.len(title) do
  --   local part = vim.fn.strcharpart(title, i)--string.char(string.byte(title, i))
  --   t = t .. (keys[part] or "")
  -- end
  title = t
  if type(config.title) == "table" then config.title = config.title[1][1] end
  if append and config.title then
    config.title = (config.title or "") .. title
  elseif type(title) == "string" then
    config.title = title
  end
  vim.api.nvim_win_set_config(M.win, config)
end

function M.setup()
  M.namespace = vim.api.nvim_create_namespace("wk_namespace")

  M.key_ns = vim.on_key(function(k)
    if k == vim.keycode("q") then
      M.close_win()
    else
      M.create_win()
      M.set_title(k, true)
    end
  end)
end

return M
