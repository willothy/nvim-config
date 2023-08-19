local function lazy(module, submodule, base)
  local name = base or "willothy.modules"
  if submodule then
    if name == "" then
      name = submodule
    else
      name = name .. "." .. submodule
    end
  end
  if name == "" then
    name = module
  else
    name = name .. "." .. module
  end

  local o = {}
  local mt = {
    __module = name,
  }
  function mt:__index(k)
    o[k] = require(name)[k]
    return rawget(o, k)
  end
  return setmetatable(o, mt)
end

local function module(mod, base)
  local name = base or "willothy.modules"
  if mod then
    if name == "" then
      name = mod
    else
      name = name .. "." .. mod
    end
  end
  local o = {}
  local mt = {
    __index = function(_, k)
      if k == "__load_all" then
        for submod_name, _ in pairs(o) do
          local submod_path = ""
          if name == "" then
            submod_path = submod_name
          else
            submod_path = name .. "." .. submod_name
          end
          local first = package.loaded[submod_path] == nil
          local submod = require(submod_path)
          if type(submod) == "table" and submod.setup and first then
            submod.setup()
          end
        end
        return function() end
      end
      local submod = require(name .. "." .. k)
      if type(submod) == "table" and submod.setup then
        submod.setup()
      end
      return submod
    end,
    __module = name,
  }
  return setmetatable(o, mt)
end

willothy = module()
willothy.fs = lazy("fs")
willothy.hl = lazy("hl")
willothy.fn = lazy("fn")
willothy.icons = lazy("icons")
willothy.keymap = lazy("keymap")
willothy.player = lazy("player")
willothy.term = lazy("terminals")
willothy.marks = lazy("marks")

willothy.utils = module("utils")
willothy.utils.cursor = lazy("cursor", "utils")
willothy.utils.window = lazy("window", "utils")
willothy.utils.tabpage = lazy("tabpage", "utils")
willothy.utils.mode = lazy("mode", "utils")
willothy.utils.plugins = lazy("plugins", "utils")
willothy.utils.debug = lazy("debug", "utils")

-- These likely won't be used directly but are exposed for ease of use

willothy.ui = module("ui")
willothy.ui.scrollbar = lazy("scrollbar", "ui")

willothy.hydras = module("hydras")
willothy.hydras.git = lazy("git", "hydras")
willothy.hydras.options = lazy("options", "hydras")
willothy.hydras.telescope = lazy("telescope", "hydras")
willothy.hydras.diagrams = lazy("diagrams", "hydras")
willothy.hydras.windows = lazy("windows", "hydras")
willothy.hydras.buffers = lazy("buffers", "hydras")
willothy.hydras.swap = lazy("swap", "hydras")

willothy.lazy = lazy
willothy.module = module

require("willothy.settings")

willothy.fs.hijack_netrw()
