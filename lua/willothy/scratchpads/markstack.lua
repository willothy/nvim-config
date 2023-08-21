local M = {}

---@class Stack
---@field push fun(self: Stack, item: any)
---@field pop fun(self: Stack): any?
---@field private _data any[]
local Stack = {}
Stack.__index = Stack

---@return Stack
function Stack.new()
  return setmetatable({ _data = {} }, Stack)
end

---@param item any
function Stack:push(item)
  table.insert(self._data, item)
end

---@return any?
function Stack:pop()
  return table.remove(self._data)
end

function Stack:clear()
  self._data = {}
end

---@class Mark
---@field buf buffer
---@field pos integer[]
---@field goto fun(self: Mark)
---@field execute fun(self: Mark, fn: fun())
local Mark = {}
Mark.__index = Mark

---@param buf buffer
---@param cursor integer[]
function Mark.new(buf, cursor)
  return setmetatable({ buf = buf, pos = cursor }, Mark)
end

function Mark:goto()
  local curbuf = vim.api.nvim_get_current_buf()
  if curbuf ~= self.buf then
    vim.api.nvim_set_current_buf(self.buf)
  end
  vim.api.nvim_win_set_cursor(0, self.pos)
end

---Execute a function with the mark as temporary cursor position
function Mark:execute(fn)
  local curbuf = vim.api.nvim_get_current_buf()
  local curwin = vim.api.nvim_get_current_win()
  local curpos = vim.api.nvim_win_get_cursor(curwin)

  self:goto()
  fn()
  if vim.api.nvim_get_current_buf() ~= curbuf then
    vim.api.nvim_set_current_buf(curbuf)
  end
  vim.api.nvim_win_set_cursor(curwin, curpos)
end

M.stack = Stack.new()

function M.mark()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(win)

  M.stack:push(Mark.new(buf, cursor))
end

function M.goto_prev() end

function M.goto_next() end

local x = Stack.new()
x:push(5)
x:clear()
vim.print(x)

return M
