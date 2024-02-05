---@class ExtList
---@field bufnr number
---@field entries table<number, string>
---@field private last_id number
local List = {}

function List:next_id()
  local id = self.last_id
  self.last_id = self.last_id + 1
  return id
end

function List:new(opts)
  local new = opts or {}

  new.bufnr = new.bufnr or vim.api.nvim_create_buf(false, true)
  new.entries = {}
  new.last_id = 0

  self.__index = self
  return setmetatable(new, self)
end

function List:add(item)
  local id = self:next_id()
  self.entries[id] = item
end

local ns = vim.api.nvim_create_namespace("extlist")

function List:render()
  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})
  local i = 0
  for id, entry in pairs(self.entries) do
    vim.api.nvim_buf_set_lines(self.bufnr, i, i + 1, false, { entry })
    vim.api.nvim_buf_set_extmark(self.bufnr, ns, i, 0, {
      -- end_col = #entry,
      url = entry,
      invalidate = true,
      undo_restore = true,
    })
    i = i + 1
  end
end

function List:open()
  local win = vim.api.nvim_open_win(self.bufnr, true, {
    split = "right",
  })

  self:render()

  local bufnr = self.bufnr
  vim.api.nvim_create_autocmd("BufLeave", {
    once = true,
    buffer = self.bufnr,
    callback = vim.schedule_wrap(function()
      if
        vim.api.nvim_win_is_valid(win)
        and vim.api.nvim_win_get_buf(win) ~= bufnr
      then
        vim.api.nvim_win_close(win, true)
      end
      vim.print(self:resolve_changes())
    end),
  })
end

function List:resolve_changes()
  local extmarks = vim.api.nvim_buf_get_extmarks(self.bufnr, ns, 0, -1, {
    details = true,
  })
  local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
  local new = {}
  local moved = {}
  local removed = {}
  local unchanged = {}

  for i, line in ipairs(lines) do
    local found = false
    if extmarks[i] and extmarks[i][4].url == line then
      table.insert(unchanged, line)
      extmarks[i][4].found = true
      found = true
    else
      for _, mark in ipairs(extmarks) do
        if mark[4].url == line then
          table.insert(moved, line)
          mark[4].found = true
          found = true
          break
        end
      end
    end
    if not found then
      table.insert(new, line)
    end
  end
  for _, mark in ipairs(extmarks) do
    if not mark[4].found then
      table.insert(removed, mark[4].url)
    end
  end
  return {
    new = new,
    moved = moved,
    removed = removed,
    unchanged = unchanged,
  }
end

local l = List:new()

l:add("test")
l:add("hello")
l:add("world")
l:add("test2")

l:open()
