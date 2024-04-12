local M = {}

local BaseTerminal = require("toggleterm.terminal").Terminal

require("configs.terminal.toggleterm")

-- require("toggleterm.constants").FILETYPE = "terminal"
require("toggleterm.constants").FILETYPE = "terminal"

local Terminal = BaseTerminal:new({
  -- cmd = "zsh",
  hidden = false,
  close_on_exit = true,
  start_in_insert = false,
  persist_size = false,
  shade_terminals = false,
  auto_scroll = false,
  highlights = {
    Normal = { link = "Normal" },
    FloatBorder = { link = "NormalFloat" },
  },
  float_opts = {
    border = "solid",
  },
})

---@param opts TermCreateArgs
---@return Terminal
---@diagnostic disable-next-line: inject-field
function Terminal:extend(opts)
  opts = opts or {}
  self.__index = self
  return setmetatable(opts--[[@as Terminal]], self)
end

M.float = Terminal:extend({
  display_name = "floating",
  direction = "float",
  on_create = function(term)
    local buf = term.bufnr
    vim.keymap.set("n", "q", function()
      term:close()
    end, { buffer = buf })
  end,
})

M.main = Terminal:extend({
  display_name = "main",
  direction = "horizontal",
  -- cmd = "tmux new -A -s nvim-main",
})

M.vertical = Terminal:extend({
  display_name = "secondary",
  direction = "vertical",
})

M.xplr = Terminal:extend({
  display_name = "xplr",
  cmd = "xplr",
  direction = "float",
})

M.yazi = Terminal:extend({
  display_name = "yazi",
  cmd = "yazi",
  direction = "vertical",
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

function M.send_to_main(cmd)
  local a = require("nio")
  a.run(function()
    if not cmd then
      cmd = a.ui.input({
        prompt = "$ ",
        completion = "shellcmd",
        highlight = function() end,
      })
    end

    if not M.main.bufnr or not vim.api.nvim_buf_is_valid(M.main.bufnr) then
      M.main:spawn()
      a.sleep(200)
    end
    if type(cmd) == "string" then
      cmd = cmd .. "\r"
    elseif type(cmd) == "table" then
      cmd[#cmd] = cmd[#cmd] .. "\r"
    end
    M.main:send(cmd)
  end)
end

function M.cargo_build()
  local p = require("fidget").progress.handle.create({
    title = "Compiling",
    lsp_client = {
      name = "cargo",
    },
  })
  vim.system(
    {
      "cargo",
      "build",
    },
    {
      text = true,
      stderr = vim.schedule_wrap(function(_, data)
        data = data or ""
        data = data:gsub("^%s+", ""):gsub("%s+$", "")
        data = vim.split(data, "\n")[1]
        if data:sub(1, #"Compiling") == "Compiling" then
          local crate, version = data:match("Compiling ([^ ]+) v([^ ]+)")
          p:report({
            message = string.format("%s %s", crate, version),
          })
        end
      end),
    },
    vim.schedule_wrap(function()
      p:finish()
    end)
  )
end

function M.get_direction(buf, win)
  win = win or vim.fn.bufwinid(buf)
  if not win then
    return
  end
  if vim.api.nvim_win_get_config(win).zindex ~= nil then
    return "float"
  end

  local layout = vim.fn.winlayout()

  local queue = { layout }
  local direction
  local last
  local current
  repeat
    last = current
    current = table.remove(queue, 1)
    if not current then
      break
    end
    if current[1] ~= "leaf" then
      for _, child in ipairs(current[2]) do
        if child[1] == "leaf" then
          if child[2] == win then
            direction = current[1]
            break
          end
        else
          table.insert(queue, child)
        end
      end
    end
  until current == nil

  if last == layout then
    if direction == "col" then
      direction = "horizontal"
    elseif direction == "row" then
      direction = "vertical"
    end
  else
    if direction == "col" then
      direction = "vertical"
    elseif direction == "row" then
      direction = "horizontal"
    end
  end
  return direction
end

return M
