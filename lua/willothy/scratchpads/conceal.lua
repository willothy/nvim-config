local ns = vim.api.nvim_create_namespace("conceal_ns")

local function conceal(pat, sub, hl, cur_line)
  vim
    .iter(vim.api.nvim_buf_get_lines(0, 0, -1, true))
    :enumerate()
    :each(function(lnr, line)
      if cur_line and lnr == cur_line then
        return
      end
      local offset = 1
      while offset < #line do
        local start, finish = string.find(line, pat, offset)
        if start == nil then
          break
        end
        vim.api.nvim_buf_set_extmark(0, ns, lnr - 1, start - 1, {
          end_line = lnr - 1,
          end_col = finish - #sub,
          conceal = "",
        })
        vim.api.nvim_buf_set_extmark(0, ns, lnr - 1, start - 1, {
          end_line = lnr - 1,
          end_col = finish,
          virt_text = { { sub, hl or "Comment" } },
          -- virt_text_pos = "inline",
          virt_text_pos = "overlay",
        })
        offset = finish
      end
    end)
end

local function clear()
  for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})) do
    vim.api.nvim_buf_del_extmark(0, ns, mark[1])
  end
end

local function exec(rules)
  clear()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  for rule in vim.iter(rules) do
    conceal(rule.pat, rule.sub, rule.hl, line - 1)
  end
  for _, mark in
    ipairs(vim.api.nvim_buf_get_extmarks(0, ns, line, line + 1, {}))
  do
    vim.api.nvim_buf_del_extmark(0, ns, mark[1])
  end
end

local rules = {
  { pat = "local", sub = "loc", hl = "Keyword" },
  { pat = "function", sub = "fun", hl = "Keyword" },
  { pat = "nvim_", sub = "" },
  { pat = "do", sub = ":", hl = "Normal" },
  { pat = "then", sub = ":", hl = "Normal" },
}

---@generic T
---@class Callable<T>
---@field arity integer
---@field args any[]
---@field fn fun(...):T
local Callable = {}
function Callable:__index(arg)
  local args = rawget(self, "args")
  table.insert(args, arg)
  if #args == rawget(self, "arity") then
    return rawget(self, "fn")(unpack(args))
  else
    return self
  end
end

function Callable:__call(...)
  for _, arg in ipairs({ ... }) do
    table.insert(self.args, arg)
  end
  if #self.args == self.arity then
    return self.fn(unpack(self.args))
  elseif #self.args > self.arity then
    error("Too many arguments")
  else
    return self
  end
end

function Callable.new(fn, arity)
  local self = setmetatable({}, Callable)
  self.fn = fn
  self.arity = arity
  self.args = {}
  return self
end

local t = Callable.new(vim.print, 2)

local _ = t[5][6]
