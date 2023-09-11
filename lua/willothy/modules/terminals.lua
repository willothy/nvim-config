local M = {}

local BaseTerminal = require("toggleterm.terminal").Terminal

require("configs.terminal.toggleterm")

-- require("toggleterm.constants").FILETYPE = "terminal"
require("toggleterm.constants").FILETYPE = "terminal"

local Terminal = BaseTerminal:new({
  cmd = "zsh",
  hidden = false,
  close_on_exit = true,
  start_in_insert = false,
  persist_size = true,
  shade_terminals = false,
  highlights = {
    Normal = { link = "NormalFloat" },
    FloatBorder = { link = "NormalFloat" },
  },
  float_opts = {
    border = "solid",
  },
  auto_scroll = false,
})

function Terminal:extend(opts)
  opts = opts or {}
  self.__index = self
  return setmetatable(opts, self)
end

M.float = Terminal:extend({
  display_name = "floating",
  direction = "float",
})

M.main = Terminal:extend({
  display_name = "main",
  direction = "horizontal",
})

M.xplr = Terminal:extend({
  display_name = "xplr",
  cmd = "xplr",
  direction = "float",
})

M.py = Terminal:extend({
  display_name = "python",
  cmd = "python3",
})

M.lua = Terminal:extend({
  display_name = "lua",
  cmd = "lua",
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
