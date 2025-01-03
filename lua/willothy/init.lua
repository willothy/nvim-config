local function metamodule(path, sub_metamodules)
  return setmetatable(sub_metamodules or {}, {
    __index = function(self, k)
      local m = require(path .. "." .. k)
      self[k] = m
      return m
    end,
  })
end

local function module(path, ...)
  local args = { ... }
  return setmetatable({}, {
    __index = function(_, k)
      local m = require(path)
      -- replace the lazy loader with the actual module so metatable,
      -- index isn't required after the initial load, but but do it
      -- some time later so we can return the value
      -- immediately and continue execution.
      vim.schedule(function()
        local t = _G
        for i, v in ipairs(args) do
          if i == #args then
            t[v] = m
            break
          end
          t = t[v]
        end
      end)
      return m[k]
    end,
  })
end

_G.willothy = metamodule("willothy", {
  ui = metamodule("willothy.ui"),
  utils = metamodule("willothy.utils"),
  async = module("nio", "willothy", "async"),
})

require("willothy.lib.fs").hijack_netrw()
