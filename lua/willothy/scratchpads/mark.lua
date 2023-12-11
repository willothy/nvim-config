local MarkRing = {}

function MarkRing:new(opts)
  opts = opts or {}
  local o = {}
  o.marks = {}
  o.head = 0
  o.tail = 0
  o.capacity = opts.capacity or 100
  setmetatable(o, self)
  self.__index = self
  return o
end

function MarkRing:insert()
  local curbuf = vim.api.nvim_get_current_buf()
  local curpos = vim.api.nvim_win_get_cursor(0)

  local mark = { buf = curbuf, pos = curpos }
  self.marks[self.head] = mark
  self.head = self.head + 1
  if self.head > self.capacity then
    self.head = 0
  end
end

function MarkRing:clear()
  self.head = 0
  self.tail = 0
  self.marks = {}
end

function MarkRing:is_empty()
  return self.head == self.tail
end

function MarkRing:next()
  if self.head == self.tail then
    return
  end
  self.tail = self.tail + 1
  if self.tail > self.capacity then
    self.tail = 0
  end
  local mark = self.marks[self.tail]
  vim.api.nvim_set_current_buf(mark.buf)
  vim.api.nvim_win_set_cursor(0, mark.pos)
end

function MarkRing:prev()
  if self.head == self.tail then
    return
  end
  self.head = self.head - 1
  if self.head < 0 then
    self.head = self.capacity
  end
  local mark = self.marks[self.head]
  vim.api.nvim_set_current_buf(mark.buf)
  vim.api.nvim_win_set_cursor(0, mark.pos)
end

-- vim.api.nvim_create_autocmd({ "BufLeave", "BufReadPost" }, {
--   callback = function()
--     require("willothy.scratchpads.mark"):insert()
--   end,
-- })
--
-- vim.keymap.set("n", "<C-n>", function()
--   require("willothy.scratchpads.mark"):prev()
--   vim.notify(vim.inspect({
--     head = require("willothy.scratchpads.mark").head,
--     tail = require("willothy.scratchpads.mark").tail,
--     len = #require("willothy.scratchpads.mark").marks,
--   }))
-- end)
--
-- vim.keymap.set("n", "<C-p>", function()
--   require("willothy.scratchpads.mark"):next()
--   vim.notify(vim.inspect({
--     head = require("willothy.scratchpads.mark").head,
--     tail = require("willothy.scratchpads.mark").tail,
--     len = #require("willothy.scratchpads.mark").marks,
--   }))
-- end)

return MarkRing:new()
