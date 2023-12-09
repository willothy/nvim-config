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

local function min(a, b, c)
  local min_val = a

  if b < min_val then
    min_val = b
  end
  if c < min_val then
    min_val = c
  end

  return min_val
end

---Taken from telescope.nvim
---@param s1 string
---@param s2 string
---@return number distance
function M.distance(s1, s2)
  if s1 == s2 then
    return 0
  end
  if s1:len() == 0 then
    return s2:len()
  end
  if s2:len() == 0 then
    return s1:len()
  end
  if s1:len() < s2:len() then
    s1, s2 = s2, s1
  end

  local t = {}
  for i = 1, #s1 + 1 do
    t[i] = { i - 1 }
  end

  for i = 1, #s2 + 1 do
    t[1][i] = i - 1
  end

  local cost
  for i = 2, #s1 + 1 do
    for j = 2, #s2 + 1 do
      cost = (s1:sub(i - 1, i - 1) == s2:sub(j - 1, j - 1) and 0) or 1
      t[i][j] = min(t[i - 1][j] + 1, t[i][j - 1] + 1, t[i - 1][j - 1] + cost)
    end
  end

  return t[#s1 + 1][#s2 + 1]
end

return M
