local ns = function(modules, submodule)
  if submodule then
    submodule = submodule .. "."
  else
    submodule = ""
  end
  return {
    __index = function(self, k)
      if modules[k] then
        local mod = require("willothy.modules." .. submodule .. k)
        if mod.setup then
          mod.setup()
        end
        rawset(self, k, mod)
        return mod
      elseif k == "__load_all" then
        for mod, _ in pairs(modules) do
          mod = require("willothy.modules." .. submodule .. mod)
          if type(mod) == "table" and mod.setup then
            mod.setup()
          end
        end
        return function() end
      else
        error("module " .. k .. " not found")
      end
    end,
    __newindex = function(_, k)
      error("cannot write to willothy." .. k)
    end,
  }
end

willothy = {}
willothy.utils = {}
willothy.hydras = {}

willothy.ns = ns

setmetatable(
  willothy,
  ns({
    fs = true,
    hl = true,
    fn = true,
    icons = true,
    keymap = true,
    player = true,
    term = true,
    scrollbar = true,
    terminals = true,
    -- "floats"
  })
)

setmetatable(
  willothy.utils,
  ns({
    cursor = true,
    window = true,
    tabpage = true,
    mode = true,
    plugins = true,
    debug = true,
  }, "utils")
)

require("willothy.settings")

willothy.fs.hijack_netrw()
