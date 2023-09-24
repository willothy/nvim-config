local M = {}

local Line = require("nui.line")
local Text = require("nui.text")

M.Line, M.Text = Line, Text

---@class veil.Window
---@field buf integer
---@field id integer
---@field config vim.api.keyset.float_config
---@field _lines NuiLine[]?
local Window = {}
Window.__index = Window

---@return veil.Window
function Window.new(config)
  local window = {}
  window.config = config
  return setmetatable(window, Window)
end

function Window:_create_buf(temp)
  if self.buf and vim.api.nvim_buf_is_valid(self.buf) then
    return self.buf
  end
  self.buf = vim.api.nvim_create_buf(false, true)
  if temp then
    vim.api.nvim_create_autocmd("BufLeave", {
      buffer = self.buf,
      callback = function()
        self:close()
      end,
    })
  end
  return self.buf
end

---@param lines NuiLine[]?
function Window:_render(lines)
  if not self:is_open() then
    return
  end
  if lines then
    self._lines = lines
  end
  for i, line in ipairs(lines or self._lines or {}) do
    line:render(self.buf, -1, i)
  end
end

function Window:is_open()
  return self.id and vim.api.nvim_win_is_valid(self.id)
end

function Window:open()
  if self:is_open() then
    return
  end
  local buf = self:_create_buf()
  self.buf = buf
  local win = vim.api.nvim_open_win(buf, true, self.config)
  self.id = win
  M.windows[win] = self
end

function Window:close()
  if not self.id then
    return
  end
  if vim.api.nvim_win_is_valid(self.id) then
    vim.api.nvim_win_close(self.id, true)
  end
  M.windows[self.id] = nil
  self.id = nil
end

function Window:set_option(name, value)
  if not self.id or not vim.api.nvim_win_is_valid(self.id) then
    return
  end
  vim.api.nvim_win_set_option(self.id, name, value)
end

function Window:hover(row, col)
  -- vim.notify("Hovered " .. row .. " " .. col .. " in " .. self.id)
end

function Window:unhover() end

function Window:click(row, col, btn)
  local button = btn
  vim.notify(
    "Clicked "
      .. row
      .. " "
      .. col
      .. " in "
      .. self.id
      .. " with button "
      .. button
  )
end

M.windows = {}

local w1 = Window.new({
  relative = "editor",
  width = 30,
  height = 10,
  col = math.floor((vim.o.columns - 30) / 2) + 30,
  row = math.floor((vim.o.lines - 10) / 2),
  style = "minimal",
  zindex = 50,
})

function w1:hover(row, col)
  for linenr, line in ipairs(self._lines or {}) do
    for _, text in ipairs(line._texts or {}) do
      vim.print(linenr .. " " .. row)
      if linenr == row then
        text:set(text._content, "YankyYanked")
      else
        text:set(text._content, "NormalFloat")
      end
    end
  end
end
w1:open()
w1:set_option("virtualedit", "all")
w1:_render({
  Line({ Text("Test", "NormalFloat") }),
  Line({ Text("Test2", "NormalFloat") }),
})

local w2 = Window.new({
  relative = "win",
  win = w1.id,
  width = 10,
  height = 1,
  col = 3,
  row = 3,
  -- col = math.floor((vim.o.columns - 30) / 2) - 30,
  -- row = math.floor((vim.o.lines - 10) / 2),
  style = "minimal",
  zindex = 201,
})
function w2:click(_, _, btn)
  vim.print("clicked")
end
function w2:hover(row, _, btn)
  local line = (self._lines or {})[1]
  for _, text in ipairs(line._texts or {}) do
    text:set(text._content, "YankyYanked")
  end
end
function w2:unhover()
  self._lines = {
    Line({ Text("Button", "NormalFloat") }),
  }
end
w2:open()
w2:_render({
  Line({ Text("Button", "NormalFloat") }),
})
w2:set_option("winhl", "Normal:NormalNC")

vim.on_key(function(key)
  if key == vim.keycode("<MouseMove>") then
    local mouse = vim.fn.getmousepos()
    if M.windows[mouse.winid] then
      if M.hovered and M.hovered.id ~= mouse.winid then
        M.hovered:unhover()
        M.hovered:_render()
        -- elseif M.hovered and M.hovered.id == mouse.winid then
        --   return
      end
      M.hovered = M.windows[mouse.winid]
      M.windows[mouse.winid]:hover(mouse.winrow, mouse.wincol)
      M.windows[mouse.winid]:_render()
    else
      M.hovered = nil
    end
  elseif key == vim.keycode("<LeftMouse>") then
    local mouse = vim.fn.getmousepos()
    if M.windows[mouse.winid] then
      M.windows[mouse.winid]:click(mouse.winrow, mouse.wincol, "l")
    end
  end
end)
