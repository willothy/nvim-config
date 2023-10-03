local function escape(str)
  return str:gsub("\\", "\\\\")
end

---@class Lines
---@field dimensions integer[]
local Lines = {}
Lines.__index = Lines

function Lines:new(data)
  local o = {}
  if type(data) == "string" then
    o.data = vim.split(data, "\n", { trimempty = false })
  elseif type(data) == "table" then
    o.data = data
  else
    error("invalid data type")
  end
  local dimensions = { #o.data, 0 }
  for _, line in ipairs(o.data) do
    dimensions[2] = math.max(dimensions[2], vim.fn.strdisplaywidth(line))
  end
  o.dimensions = dimensions
  return setmetatable(o, Lines)
end

function Lines:width()
  return self.dimensions[2]
end

function Lines:height()
  return self.dimensions[1]
end

function Lines:truncate_width(width)
  local lines = {}
  for _, line in ipairs(self.data) do
    table.insert(lines, line:sub(1, width))
  end
  return Lines:new(lines)
end

function Lines:truncate_height(height, start)
  if not start then
    start = 1
  end
  if start > self:height() then
    return Lines:new({})
  end
  local lines = {}
  for i = start, height + start do
    if self.data[i] then
      table.insert(lines, self.data[i])
    end
  end
  return Lines:new(lines)
end

---@param dimensions Lines | integer[]
function Lines:empty(dimensions)
  local dims
  if getmetatable(dimensions) == Lines then
    dims = dimensions.dimensions
  else
    dims = dimensions
  end
  local lines = {}
  for _ = 1, dims[1] do
    table.insert(lines, string.rep(" ", dims[2]))
  end
  return Lines:new(lines)
end

function Lines:escape()
  for i, line in ipairs(self.data) do
    self.data[i] = escape(line)
  end
  return self
end

function Lines:trim_trailing_whitespace()
  local lines = {}
  for i, line in ipairs(self.data) do
    lines[i] = line:gsub("%s+$", "")
  end
  return Lines:new(lines)
end

function Lines:overlay(other, row, col, force)
  if force == nil then
    force = false
  end
  if not row then
    row = 1
  end
  if not col then
    col = 1
  end

  if row < 0 then
    row = #self.data + row + 1
  end
  if col < 0 then
    col = vim.fn.strdisplaywidth(self.data[row]) + (col + 1)
  end

  local i = 0
  self.data = setmetatable(
    vim.list_extend(
      vim.list_slice(self.data, 1, row - 1),
      vim
        .iter(self.data)
        :skip(row - 1)
        :map(function(line, e)
          if type(line) ~= "string" then
            line = e
          end
          i = i + 1
          local other_line = other.data[i]
          if not other_line then
            return line
          end
          local new = col > 1 and vim.fn.strcharpart(line, 0, col - 2) or ""
          for j = col, #line do
            local l1_char = vim.fn.strcharpart(line, j - 1, 1)
            local l2_char = vim.fn.strcharpart(other_line, j - col, 1)

            if
              j < col
              or j > (col + #other_line)
              or l2_char == nil
              or l2_char == ""
              or (force == false and string.match(l2_char, "%s+") ~= nil)
            then
              new = new .. l1_char
            else
              new = new .. l2_char
            end
          end
          return new
        end)
        :totable()
    ),
    Lines
  )

  return self
end

function Lines:render()
  return table.concat(self.data, "\n")
end

function Lines:actions(actions, width, fmt)
  local processed = {}
  for _, action in ipairs(actions) do
    if action.key ~= "" then
      table.insert(
        processed,
        string.format(fmt or "_%s_: %s", action.key, action.desc)
      )
    else
      table.insert(processed, action.desc)
    end
  end
  actions = processed

  local lines = {}

  local left_col = {}
  local right_col = {}

  for i, action in ipairs(actions) do
    if i % 2 == 1 then
      table.insert(left_col, action)
    else
      table.insert(right_col, action)
    end
  end

  for left, right in
    vim.iter(left_col):enumerate():map(function(i, l)
      return l, right_col[i]
    end)
  do
    local line
    local left_len = #left
    local right_len = #(right or "")
    local available = width or 32

    available = available - (right_len > 0 and 2 or 0)

    local l_available = right_len > 0 and math.floor(available / 2)
      or available
    local r_available = available - l_available

    if left_len > l_available then
      left = left:sub(1, l_available - 1) .. ""
    elseif left_len < l_available then
      left = left .. string.rep(" ", l_available - left_len)
    end

    if right_len > r_available then
      right = right:sub(1, r_available - 1) .. ""
    elseif right_len < r_available then
      right = right .. string.rep(" ", r_available - right_len)
    end

    if right_len > 0 then
      line = left .. "  " .. right
    else
      line = left
    end

    table.insert(lines, line)
  end
  return Lines:new(lines)
end

return Lines
