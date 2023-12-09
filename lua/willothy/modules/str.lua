local M = {}

function M.rpad(str, len, char)
  char = char or " "
  return str .. string.rep(char, len - #str)
end

function M.lpad(str, len, char)
  char = char or " "
  return string.rep(char, len - #str) .. str
end

function M.trim(str)
  return string.match(str, "^%s*(.-)%s*$")
end

function M.trim_trailing_whitespace(str)
  return string.gsub(str, "%s+$", "")
end

function M.longest_line(lines)
  if type(lines) == "string" then
    lines = vim.split(lines, "\n")
  end
  local longest = 0
  for _, line in ipairs(lines) do
    longest = math.max(longest, #line)
  end
  return longest
end

function M.rpad_lines(lines, len, char)
  char = char or " "
  if type(lines) == "string" then
    lines = vim.split(lines, "\n")
  end
  len = math.max(M.longest_line(lines), len)
  local padded = {}
  for _, line in ipairs(lines) do
    table.insert(padded, M.rpad(line, len, char))
  end
  return padded
end

function M.lpad_lines(lines, len, char)
  char = char or " "
  if type(lines) == "string" then
    lines = vim.split(lines, "\n")
  end
  len = math.max(M.longest_line(lines), len)
  local padded = {}
  for _, line in ipairs(lines) do
    table.insert(padded, M.lpad(line, len, char))
  end
  return padded
end

function M.pad_lines(lines, len, char)
  char = char or " "
  if type(lines) == "string" then
    lines = vim.split(lines, "\n")
  end
  local longest = M.longest_line(lines)
  local amount = math.max(0, len - longest)
  local l = string.rep(char, math.floor(amount / 2))
  local r = string.rep(char, math.ceil(amount / 2))

  local function pad(line)
    line = M.rpad(line, longest, char)
    line = l .. line .. r
    return line
  end

  local padded = {}
  for _, line in ipairs(lines) do
    table.insert(padded, pad(line))
  end
  return padded
end

---@class Trie
---@field private children table<string, Trie>
---@field private is_end boolean
local Trie = {}
Trie.__index = Trie
Trie.__newindex = function()
  error("Cannot inject fields into Trie")
end
Trie.__metatable = "Trie"

---@return Trie
function Trie.new()
  return setmetatable({
    children = {},
    is_end = false,
  }, Trie)
end

---@param iterable string[] | table<number, string> | Iter | fun(...:any):...:string
function Trie.from_iter(iterable)
  local self = Trie.new()
  for str in vim.iter(iterable) do
    self:insert(str)
  end
  return self
end

---@param s string
function Trie:insert(s)
  local node = self
  for i = 1, #s do
    local ch = s:sub(i, i)

    if not node.children[ch] then
      node.children[ch] = Trie.new()
    end
    node = node.children[ch]
  end
  node.is_end = true
end

---@param s string
---@return boolean
function Trie:contains(s)
  local node = self
  for ch in s:gmatch(".") do
    if not node.children[ch] then
      return false
    end
    node = node.children[ch]
  end
  return true
end

---@private
function Trie:_remove(s, i)
  if i == #s then
    self.is_end = false
    return #self.children == 0
  end
  local ch = s:sub(i, i)
  local next
  if self.children[ch] then
    next = self.children[ch]:_remove(s, i + 1)
    if next then
      self.children[ch] = nil
    end
  end
  return next and not self.is_end and #self.children == 0
end

function Trie:remove(s)
  self:_remove(s, 1)
end

---@private
function Trie:_matches(prefix, results, i)
  if i > #prefix then
    for byte = 96, 122 do
      local ch = string.char(byte)
      local child = self.children[ch]
      if child then
        if child.is_end then
          table.insert(results, prefix .. ch)
        end
        child:_matches(prefix .. ch, results, i + 1)
      end
    end
  else
    local ch = prefix:sub(i, i)
    if self.children[ch] then
      return self.children[ch]:_matches(prefix, results, i + 1)
    end
  end

  return results
end

function Trie:matches(prefix)
  return self:_matches(prefix, {}, 1)
end

M.Trie = Trie

return M
