---@class Focus.View
---@field topline number
---@field leftcol number
---@field lnum number
---@field col number
---@field curswant number
local View = {
  topline = 0,
  leftcol = 0,
  lnum = 0,
  col = 0,
  curswant = 0,
}

---@param id window
---@return Focus.View
function View.new(id)
  local self = setmetatable({}, { __index = View })
  local info = vim.api.nvim_win_call(id, vim.fn.winsaveview)
  self.topline = info.topline
  self.leftcol = info.leftcol
  self.lnum = info.lnum
  self.col = info.col
  self.curswant = info.curswant
  return self
end

---@param id window
function View:apply(id)
  vim.api.nvim_win_call(id, function()
    vim.fn.winrestview(self)
  end)
end

---@class Focus.Window
---@field wincol number
---@field winrow number
---@field width number
---@field height number
---@field id number
---@field view Focus.View
---@field parent Focus.Layout
local Window = {
  wincol = 0,
  winrow = 0,
  width = 0,
  height = 0,
  id = 0,
  view = nil,
}
Window.__index = Window

---@return Focus.Window
function Window.new(id)
  if not vim.api.nvim_win_is_valid(id) then return end
  local self = setmetatable({}, Window)
  local info = vim.fn.getwininfo(id)
  self.wincol = info.wincol
  self.winrow = info.winrow
  self.width = info.width
  self.height = info.height
  self.id = id
  self.view = View.new(id)
  return self
end

function Window:fetch()
  if not vim.api.nvim_win_is_valid(self.id) then return end
  local info = vim.fn.getwininfo(self.id)
  self.wincol = info.wincol
  self.winrow = info.winrow
  self.width = info.width
  self.height = info.height
  self.view = View.new(self.id)
end

function Window:update(width, height, view)
  if width then self.width = width end
  if height then self.height = height end
  if view then self.view = view end
end

function Window:draw()
  if not vim.api.nvim_win_is_valid(self.id) then return end
  local cur_w = vim.api.nvim_win_get_width(self.id)
  local cur_h = vim.api.nvim_win_get_height(self.id)
  if cur_w ~= self.width then
    vim.api.nvim_win_set_width(self.id, self.width)
  end
  if cur_h ~= self.height then
    vim.api.nvim_win_set_height(self.id, self.height)
  end
  if not vim.deep_equal(self.view, View.new(self.id)) then
    self.view:apply(self.id)
  end
end

function Window:compute(width, height)
  self.width = width
  self.height = height
end

---@class Focus.Layout
---@field wincol number
---@field winrow number
---@field width number
---@field height number
---@field direction "col" | "row" | "leaf" Can only be leaf if there is one window
---@field children Focus.Window[]
---@field dirty boolean
local Layout = {
  wincol = 0,
  winrow = 0,
  width = 0,
  height = 0,
  direction = "col",
  children = {},
  dirty = true,
}
Layout.__index = Layout

---@return Focus.Layout
function Layout.new(node)
  local self = setmetatable({}, Layout)
  self.direction = node[1]
  self.children = {}
  if node[1] == "leaf" then
    table.insert(self.children, Window.new(node[2]))
    return self
  else
    for _, child in ipairs(node[2]) do
      if type(child) == "table" then
        table.insert(self.children, Layout.new(child))
      else
        table.insert(self.children, Window.new(child))
      end
    end
  end
  return self
end

---@return Focus.Window[]
function Layout:windows()
  local windows = {}
  for _, child in ipairs(self.children) do
    if getmetatable(child) == Layout then
      for _, window in ipairs(child:windows()) do
        windows[window.id] = window
      end
    else
      windows[child.id] = child
    end
  end
  return windows
end

function Layout:compute(width, height)
  if self.direction == "col" then
    local total_width = 0
    for _, child in ipairs(self.children) do
      child:compute(width, math.floor(height / math.max(1, #self.children)))
      total_width = total_width + child.width
    end
    self.width = total_width
    self.height = height
  else
    local total_height = 0
    for _, child in ipairs(self.children) do
      child:compute(math.floor(width / math.max(1, #self.children)), height)
      total_height = total_height + child.height
    end
    self.width = width
    self.height = total_height
  end
end

function Layout:draw()
  for i, child in ipairs(self.children) do
    if getmetatable(child) == Window then
      if vim.api.nvim_win_is_valid(child.id) then
        child:draw()
      else
        self.children[i] = nil
      end
    else
      child:draw()
    end
  end
end

---@class Focus.Tree
---@field windows table<window, Focus.Window>
---@field layout Focus.Layout
local Tree = {
  windows = {},
  layout = {},
}
Tree.__index = Tree

function Tree.new()
  local self = setmetatable({}, Tree)
  self.layout = Layout.new(vim.fn.winlayout())
  self.windows = self.layout:windows()
  return self
end

function Tree:compute(width, height)
  -- just a simple wrapper for now
  self.layout:compute(width, height)
end

function Tree:draw()
  -- same
  self.layout:draw()
end

function Tree:fetch()
  self.layout = Layout.new(vim.fn.winlayout())
  self.windows = self.layout:windows()
end

function Tree:current_win()
  local curwin = vim.api.nvim_get_current_win()
  for _, win in pairs(self.windows) do
    if win.id == curwin then return win end
  end
end

local tree = Tree.new()

vim.api.nvim_create_autocmd({ "WinNew", "WinClosed" }, {
  callback = function()
    tree:fetch()
    tree:compute(vim.o.columns, vim.o.lines)
    tree:draw()
  end,
})

vim.api.nvim_create_autocmd({ "WinResized", "VimResized" }, {
  callback = function()
    tree:compute(vim.o.columns, vim.o.lines)
    tree:draw()
  end,
})

vim.api.nvim_create_autocmd("WinEnter", {
  callback = function()
    local cur = tree:current_win()
    if not cur then
      tree:fetch()
      cur = tree:current_win()
    end
    if cur then cur:update(160, 60) end
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  callback = function()
    tree:draw()
  end,
})

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
  callback = function()
    local cur = tree:current_win()
    if cur then
      cur:update(160, 60)
      cur:draw()
    else
      tree:fetch()
      cur = tree:current_win()
      if cur then
        cur:update(160, 60)
        cur:draw()
      end
    end
  end,
})

vim.api.nvim_create_autocmd("WinLeave", {
  callback = function()
    local cur = tree:current_win()
    if cur then
      cur:fetch()
    else
      tree:fetch()
      tree:compute(vim.o.columns, vim.o.lines)
      tree:draw()
    end
  end,
})
