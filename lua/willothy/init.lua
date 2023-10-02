local function module()
  local submodules = {}
  local setup = {}

  local mt = {}

  function mt:__index(k)
    if not submodules[k] then
      return
    end
    local mod
    if type(submodules[k]) == "table" then
      mod = submodules[k]
    else
      mod = require("willothy.modules." .. submodules[k])
    end
    if not setup[k] then
      if mod.setup then
        mod.setup()
      end
      setup[k] = true
    end
    return mod
  end
  function mt:__newindex(k, v)
    submodules[k] = v
  end

  local m = {}

  function m.setup()
    for k in pairs(submodules) do
      if not setup[k] then
        if m[k].setup then
          m[k].setup()
        end
        setup[k] = true
      end
    end
  end

  return setmetatable(m, mt)
end

willothy = module()
willothy.fs = "fs"
willothy.hl = "hl"
willothy.fn = "fn"
willothy.rx = "rx"
willothy.icons = "icons"
willothy.keymap = "keymap"
willothy.player = "player"
willothy.term = "terminals"
willothy.event = "event"

willothy.utils = module()
willothy.utils.cursor = "utils.cursor"
willothy.utils.window = "utils.window"
willothy.utils.buf = "utils.buf"
willothy.utils.tabpage = "utils.tabpage"
willothy.utils.mode = "utils.mode"
willothy.utils.plugins = "utils.plugins"
willothy.utils.debug = "utils.debug"
willothy.utils.table = "utils.table"
willothy.utils.progress = "utils.progress"

willothy.ui = module()
willothy.ui.scrollbar = "ui.scrollbar"
willothy.ui.float_drag = "ui.float_drag"
willothy.ui.select = "ui.select"
willothy.ui.code_actions = "ui.code_actions"

willothy.hydras = module()
willothy.hydras.git = "hydras.git"
willothy.hydras.options = "hydras.options"
willothy.hydras.telescope = "hydras.telescope"
willothy.hydras.diagrams = "hydras.diagrams"
willothy.hydras.windows = "hydras.windows"
willothy.hydras.buffers = "hydras.buffers"
willothy.hydras.swap = "hydras.swap"

require("willothy.settings")

return {
  setup = function()
    willothy.fs.hijack_netrw()
  end,
}
