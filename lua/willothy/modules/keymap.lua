local M = {}

-- TODO: this sucks. never works. use which-key or hawtkeys for this.
function M.find(mode, lhs)
  local map = vim.api.nvim_get_keymap(mode)
  vim.list_extend(map, vim.api.nvim_buf_get_keymap(0, mode))
  local raw = vim.api.nvim_replace_termcodes(lhs, true, false, false)

  for _, m in ipairs(map) do
    if m.lhs == lhs or m.lhsraw == raw or m.lhsraw == lhs then
      return m
    end
  end
end

local group = function(obj)
  return setmetatable(obj, {
    __add = function(self, other)
      local modes = {}
      if type(other) == "string" then
        for _, mode in ipairs(self) do
          table.insert(modes, mode)
        end
        table.insert(modes, other)
      elseif type(other) == "table" then
        for _, mode in ipairs(self) do
          table.insert(modes, mode)
        end
        for _, mode in ipairs(other) do
          table.insert(modes, mode)
        end
      end
      return modes
    end,
  })
end

M.modes = setmetatable({
  normal = "n",
  visual = "v",
  insert = "i",
  command = "c",
  terminal = "t",
  pending = "o",
  select = "s",
  visualblock = "x",
  replace = "r",
  non_editing = group({ "n", "x", "v" }),
  non_pending = group({ "n", "x", "v", "s", "i", "c", "t" }),
  basic = group({ "n", "x", "v", "i", "c", "t" }),
  all = group({ "n", "x", "v", "s", "i", "c", "t", "o" }),
}, {
  __index = function(self, k)
    if k == "empty" then
      return group({})
    end
    return rawget(self, k)
  end,
})

-- This is terrible I don't know why I wrote this.
-- FIXME: get rid of this asap just write mappings normally
local Binding = {}
Binding.__index = Binding
Binding.__call = function(self, ...)
  self[1](...)
end

M.Binding = Binding

---@param map fun() | string
---@param desc string?
function Binding.new(map, desc)
  return setmetatable({ map, desc }, Binding)
end

function Binding:with_desc(desc)
  self[2] = desc
  return self
end

function M.bind(mod, name, ...)
  local args = { ... }

  local fn = function()
    if type(mod) == "string" then
      require(mod)[name](unpack(args))
    elseif type(mod) == "function" then
      mod(name, unpack(args))
    elseif type(mod) == "table" then
      mod[name](unpack(args))
    end
  end

  local desc
  local display_name = (name or ""):gsub("[-_]", " ")
  if type(mod) == "string" then
    desc = ("%s: %s"):format(mod, display_name)
  else
    desc = ("%s"):format(display_name)
  end

  return Binding.new(fn, desc)
end

function M.group(mode, prefix, name, noleader)
  local ok, wk = pcall(require, "which-key")
  if not ok then
    return
  end
  wk.register(
    { name = name },
    { mode = mode, prefix = noleader and prefix or ("<leader>" .. prefix) }
  )
end

return M
