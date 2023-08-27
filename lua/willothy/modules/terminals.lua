local M = {}

local Terminal = require("toggleterm.terminal").Terminal

-- require("toggleterm.constants").FILETYPE = "terminal"
require("toggleterm.constants").FILETYPE = "terminal"

M.float = Terminal:new({
  display_name = "floating",
  filetype = "toggleterm_float",
  cmd = "zsh",
  hidden = false,
  direction = "float",
  float_opts = {
    border = "none",
  },
  close_on_exit = true,
  start_in_insert = true,
  on_open = function()
    vim.api.nvim_exec_autocmds(
      "User",
      { pattern = "UpdateHeirlineComponents" }
    )
    vim.defer_fn(vim.cmd.startinsert, 40)
  end,
})

M.main = Terminal:new({
  display_name = "main",
  cmd = "zsh",
  hidden = false,
  close_on_exit = true,
  direction = "horizontal",
  start_in_insert = true,
  shade_terminals = false,
  highlights = {
    Normal = { link = "Normal" },
  },
  on_open = function()
    vim.api.nvim_exec_autocmds(
      "User",
      { pattern = "UpdateHeirlineComponents" }
    )
    vim.defer_fn(vim.cmd.startinsert, 40)
  end,
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
  local term = willothy.term.main
  if term:is_open() then
    if edgy then
      local win = require("edgy").get_win(term.window)
      if win and not win.visible then
        win:open()
      end
    end
  else
    term:open()
  end
  return term
end

function M.with_float()
  local term = willothy.term.float
  if term:is_open() then
    if edgy then
      local win = edgy.get_win(term.window)
      if win and not win.visible then
        win:open()
      end
    end
  else
    term:open()
  end
  return term
end

function M.toggle()
  local term = willothy.term.main
  if term:is_open() then
    if edgy then
      local win = edgy.get_win(term.window)
      if vim.api.nvim_get_mode().mode == "t" then
        vim.cmd("stopinsert!")
      end
      vim.schedule(function()
        if win and win.visible then
          win:close()
        elseif win then
          win:open()
        end
      end)
    else
      term:close()
    end
  else
    term:open()
  end
end

function M.toggle_float()
  M.float:toggle()
end

return M
