local Iter = getmetatable(vim.iter({}))

function Iter:chain(...)
  local iters = { self, ... }
  local curr = 1

  function next()
    if curr > #iters then
      return nil
    end
    local val = vim.F.pack_len(iters[curr]:next())
    if val.n == 0 then
      curr = curr + 1
      return next()
    end
    return vim.F.unpack_len(val)
  end

  return vim.iter(next)
end

local d1 = { 1, 2, 3, 4 }
local d2 = { 5, 6, 7, 8 }

local t1 = vim.iter(d1)
local t2 = vim.iter(d2)

---@type Iter
local t3 = t1:chain(t2):enumerate()

local res = t3:totable()
print(res)
