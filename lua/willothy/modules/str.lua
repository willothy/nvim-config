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

  return vim.iter.map(pad, lines)
end

return M
