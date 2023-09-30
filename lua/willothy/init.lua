local function lazy(module)
  local mt = {}
  function mt:__index(k)
    if not package.loaded[module] then
      local mod = require(module)
      if rawget(mod, "setup") then
        mod.setup()
      end
      return mod[k]
    end
    return require(module)[k]
  end
  function mt:__newindex(k, v)
    require(module)[k] = v
  end
  return setmetatable({}, mt)
end

local base = "willothy.modules."

willothy = {}
willothy.fs = lazy(base .. "fs")
willothy.hl = lazy(base .. "hl")
willothy.fn = lazy(base .. "fn")
willothy.rx = lazy(base .. "rx")
willothy.icons = lazy(base .. "icons")
willothy.keymap = lazy(base .. "keymap")
willothy.player = lazy(base .. "player")
willothy.term = lazy(base .. "terminals")
willothy.event = lazy(base .. "event")

willothy.utils = {}
willothy.utils.cursor = lazy(base .. "utils.cursor")
willothy.utils.window = lazy(base .. "utils.window")
willothy.utils.buf = lazy(base .. "utils.buf")
willothy.utils.tabpage = lazy(base .. "utils.tabpage")
willothy.utils.mode = lazy(base .. "utils.mode")
willothy.utils.plugins = lazy(base .. "utils.plugins")
willothy.utils.debug = lazy(base .. "utils.debug")
willothy.utils.table = lazy(base .. "utils.table")
willothy.utils.progress = lazy(base .. "utils.progress")

willothy.ui = {}
willothy.ui.scrollbar = lazy(base .. "ui.scrollbar")
willothy.ui.scrolleof = lazy(base .. "ui.scrolleof")
willothy.ui.float_drag = lazy(base .. "ui.float_drag")
willothy.ui.select = lazy(base .. "ui.select")

willothy.hydras = {}
willothy.hydras.git = lazy(base .. "hydras.git")
willothy.hydras.options = lazy(base .. "hydras.options")
willothy.hydras.telescope = lazy(base .. "hydras.telescope")
willothy.hydras.diagrams = lazy(base .. "hydras.diagrams")
willothy.hydras.windows = lazy(base .. "hydras.windows")
willothy.hydras.buffers = lazy(base .. "hydras.buffers")
willothy.hydras.swap = lazy(base .. "hydras.swap")

willothy.lazy = lazy

require("willothy.settings")

return {
  setup = function()
    willothy.fs.hijack_netrw()
  end,
}
