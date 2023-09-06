local M = {}

local Terminal = require("toggleterm.terminal").Terminal

-- require("toggleterm.constants").FILETYPE = "terminal"
require("toggleterm.constants").FILETYPE = "terminal"

M.float = Terminal:new({
  display_name = "floating",
  cmd = "zsh",
  hidden = false,
  direction = "float",
  close_on_exit = true,
  start_in_insert = false,
  persist_size = true,
  highlights = {
    Normal = { link = "NormalFloat" },
    FloatBorder = { link = "NormalFloat" },
  },
  float_opts = {
    border = "solid",
  },
})

M.main = Terminal:new({
  display_name = "main",
  cmd = "zsh",
  hidden = false,
  direction = "horizontal",
  close_on_exit = true,
  start_in_insert = false,
  auto_scroll = false,
  persist_size = true,
  shade_terminals = false,
  highlights = {
    Normal = { link = "Normal" },
    FloatBorder = { link = "NormalFloat" },
  },
})

M.py = Terminal:new({
  display_name = "python",
  cmd = "python3",
  hidden = true,
})

M.lua = Terminal:new({
  cmd = "lua",
  hidden = true,
})

function M.job(cmd)
  local args = {}
  if type(cmd) == "table" then
    args = cmd
    cmd = table.remove(cmd, 1)
  end
  local overseer = require("overseer")
  ---@type overseer.Task
  local task = overseer.new_task({
    cmd = cmd,
    args = args,
    name = cmd,
  })
  task:subscribe(
    "on_complete",
    vim.schedule_wrap(function()
      if not overseer.window.is_open() then
        overseer.open({ enter = false, direction = "left" })
      end
    end)
  )
  task:start()
  return task
end

function M.toggle()
  M.main:toggle()
end

function M.toggle_float()
  M.float:toggle()
end

return M
