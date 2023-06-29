local M = {}

local Terminal = require("toggleterm.terminal").Terminal

require("toggleterm.constants").FILETYPE = "terminal"

M.float = Terminal:new({
  display_name = "floating",
  filetype = "toggleterm_float",
  cmd = "zsh",
  hidden = false,
  direction = "float",
  float_opts = {
    border = "rounded",
  },
  close_on_exit = true,
})

M.main = Terminal:new({
  display_name = "main",
  cmd = "zsh",
  hidden = false,
  close_on_exit = true,
  direction = "horizontal",
  start_in_insert = false,
})

M.py = Terminal:new({
  cmd = "python3",
  hidden = true,
})

M.lua = Terminal:new({
  cmd = "lua",
  hidden = true,
})

local edgy = (function()
  local ok, res = pcall(require, "edgy")
  return ok and res or nil
end)()

---@return Terminal
function M.with()
  local term = require("willothy.terminals").main
  if term:is_open() then
    if edgy then
      local win = require("edgy").get_win(term.window)
      if win and not win.visible then win:open() end
    end
  else
    term:open()
  end
  return term
end

function M.with_float()
  local term = require("willothy.terminals").float
  if term:is_open() then
    if edgy then
      local win = edgy.get_win(term.window)
      if win and not win.visible then win:open() end
    end
  else
    term:open()
  end
  return term
end

function M.toggle()
  local term = require("willothy.terminals").main
  if term:is_open() then
    if edgy then
      local win = edgy.get_win(term.window)
      if win and win.visible then
        win:close()
      elseif win then
        win:open()
      end
    else
      term:close()
    end
  else
    term:open()
  end
end

function M.toggle_float() M.float:toggle() end

return M
