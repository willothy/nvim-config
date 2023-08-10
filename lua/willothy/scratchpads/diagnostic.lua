---@class Position
---@field line integer
---@field col  integer
local Position = {}

function Position:__index(key)
  --
  return rawget(Position, key)
end

function Position:__eq(other)
  return self.line == other.line and self.col == other.col
end

function Position:__add(other)
  return Position:new(self.line + other.line, self.col + other.col)
end

function Position:__sub(other)
  return Position:new(self.line - other.line, self.col - other.col)
end

function Position:__mul(other)
  return Position:new(self.line * other.line, self.col * other.col)
end

function Position:__div(other)
  return Position:new(self.line / other.line, self.col / other.col)
end

function Position:__lt(other)
  if self.line < other.line then
    return true
  end
  if self.line > other.line then
    return false
  end
  return self.col < other.col
end

function Position:__le(other)
  if self.line < other.line then
    return true
  end
  if self.line > other.line then
    return false
  end
  return self.col <= other.col
end

function Position:__tostring()
  return string.format("(%d, %d)", self.line, self.col)
end

function Position:new(line, col)
  local o = { line = line, col = col }
  setmetatable(o, Position)
  return o
end

---@class Range
---@field start Position
---@field end_  Position
---@field bufnr buffer
local Range = {}

function Range:__eq(other)
  return self.start == other.start and self.end_ == other.end_
end

function Range:__tostring()
  return string.format("%s - %s", self.start, self.end_)
end

function Range:new(start, end_, file)
  local o = { start = start, end_ = end_, file = file }
  setmetatable(o, Range)
  return o
end

---@enum Severity
local Severity = {
  [vim.diagnostic.severity.ERROR] = "E",
  [vim.diagnostic.severity.WARN] = "W",
  [vim.diagnostic.severity.INFO] = "I",
  [vim.diagnostic.severity.HINT] = "H",
}

---@class Diagnostic
---@field range    Range
---@field severity Severity
---@field message  string
---@field code     string
---@field source   string
---@field ns       integer
local Diagnostic = {}

local function diagfloat()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  local fetched =
    { { col = 2, row = 1, severity = 1 }, { col = 0, row = 1, severity = 2 } } -- vim.diagnostic.get(0)
  local diagnostics = vim
    .iter(fetched)
    :map(function(d)
      if d.col < d.end_col then
        d.col, d.end_col = d.end_col, d.col
      end
    end)
    :totable()

  vim.print(diagnostics)
end
