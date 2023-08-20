local function lazy(module, submodule)
  local name = "willothy.modules"
  if submodule then
    name = name .. "." .. submodule
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
  local ready = false
  function mt:__index(k)
    o = require(name)
    if o.setup and not ready then
      o.setup()
      ready = true
    end
    if submodule then
      willothy[submodule][module] = o
    else
      willothy[module] = o
    end
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
      local function load(submod_name)
        local submod_path = ""
        if name == "" then
          submod_path = submod_name
        else
          submod_path = name .. "." .. submod_name
        end
        local first = package.loaded[submod_path] == nil
        local submod = require(submod_path)
        o[submod_name] = submod
        if first and type(submod) == "table" and submod.setup then
          submod.setup()
        end
        return submod
      end
      if k == "__load_all" then
        return function()
          for submod_name, _ in pairs(o) do
            load(submod_name)
          end
        end
      end
      return load(k)
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
willothy.utils.table = lazy("table", "utils")

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
