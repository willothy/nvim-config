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
function Trie:has(s)
  local node = self
  for ch in s:gmatch(".") do
    local next = node.children[ch]
    if not next then
      return false
    end
    node = node.children[ch]
  end
  return node.is_end
end

---@private
function Trie:_remove(s, i)
  if i > #s then
    self.is_end = false
    return next(self.children) == nil
  end
  local ch = s:sub(i, i)
  local pruned = false
  if self.children[ch] then
    if self.children[ch]:_remove(s, i + 1) then
      self.children[ch] = nil
      pruned = true
    end
  end
  return pruned and not self.is_end and next(self.children) == nil
end

function Trie:remove(s)
  self:_remove(s, 1)
end

---@private
function Trie:_matches(prefix, results, i)
  if i > #prefix then
    -- enumerate every child; keys may be uppercase, digits, '_', '-', '.', '/'
    for ch, child in pairs(self.children) do
      if child.is_end then
        table.insert(results, prefix .. ch)
      end
      child:_matches(prefix .. ch, results, i + 1)
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

return Trie
