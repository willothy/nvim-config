local M = {}

function M.find(mode, lhs)
  local map = vim.api.nvim_get_keymap(mode)
  local raw = vim.api.nvim_replace_termcodes(lhs, true, false, false)

  for _, m in ipairs(map) do
    if m.lhs == lhs or m.lhsraw == raw then return m end
  end
end

function M.register(tree, modes, prefix)
  local function traverse(node, lhs, key)
    local t = type(node)
    if
      t ~= "table"
      or type(node[1]) == "string"
      or type(node[1]) == "function"
    then
      local rhs, opts
      if t == "function" or t == "string" then
        if key == "name" then
          if _G.__key_prefixes == nil then _G.__key_prefixes = {} end
          for _, mode in ipairs(modes) do
            if not _G.__key_prefixes[mode] then _G.__key_prefixes[mode] = {} end
            _G.__key_prefixes[mode][lhs] = node
          end
          return
        end
        rhs = node
        opts = {}
      else
        rhs = node[1]
        opts = {
          desc = node.desc or node[2],
          silent = node.silent,
          expr = node.expr,
          noremap = node.noremap,
        }
      end
      vim.keymap.set(modes, lhs, rhs, opts)
    else
      for k, v in pairs(node) do
        traverse(v, lhs .. k, k)
      end
    end
  end
  traverse(tree, prefix or "")
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
  all = group({ "n", "x", "v", "s", "i", "c", "t", "o", "r" }),
}, {
  __index = function(self, k)
    if k == "empty" then return group({}) end
    return rawget(self, k)
  end,
})

function M.bind(module, name, ...)
  local args = { ... }

  return function()
    if type(module) == "string" then
      require(module)[name](unpack(args))
    elseif type(module) == "function" then
      module(name, unpack(args))
    end
  end
end

return M
