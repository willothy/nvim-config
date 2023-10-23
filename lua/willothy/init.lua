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
      if type(mod) == "table" and vim.is_callable(mod.setup) then
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
        if type(m[k]) == "table" and vim.is_callable(m[k].setup) then
          m[k].setup()
        end
        setup[k] = true
      end
    end
  end

  return setmetatable(m, mt)
end

---@diagnostic disable: assign-type-mismatch
willothy = module()
---@module "willothy.modules.fs"
willothy.fs = "fs"
---@module "willothy.modules.hl"
willothy.hl = "hl"
---@module "willothy.modules.fn"
willothy.fn = "fn"
---@module "willothy.modules.rx"
willothy.rx = "rx"
---@module "willothy.modules.icons"
willothy.icons = "icons"
---@module "willothy.modules.keymap"
willothy.keymap = "keymap"
---@module "willothy.modules.player"
willothy.player = "player"
---@module "willothy.modules.terminals"
willothy.term = "terminals"
---@module "willothy.modules.event"
willothy.event = "event"
---@module "willothy.modules.win"
willothy.win = "win"
---@module "willothy.modules.buf"
willothy.buf = "buf"
---@module "willothy.modules.tab"
willothy.tab = "tab"

willothy.utils = module()
---@module "willothy.modules.utils.cursor"
willothy.utils.cursor = "utils.cursor"
---@module "willothy.modules.utils.mode"
willothy.utils.mode = "utils.mode"
---@module "willothy.modules.utils.plugins"
willothy.utils.plugins = "utils.plugins"
---@module "willothy.modules.utils.debug"
willothy.utils.debug = "utils.debug"
---@module "willothy.modules.utils.table"
willothy.utils.table = "utils.table"
---@module "willothy.modules.utils.progress"
willothy.utils.progress = "utils.progress"
---@module "willothy.modules.utils.templates"
willothy.utils.templates = "utils.templates"

willothy.ui = module()
---@module "willothy.modules.ui.scrollbar"
willothy.ui.scrollbar = "ui.scrollbar"
---@module "willothy.modules.ui.scrolleof"
willothy.ui.scrolleof = "ui.scrolleof"
---@module "willothy.modules.ui.float_drag"
willothy.ui.float_drag = "ui.float_drag"
---@module "willothy.modules.ui.select"
willothy.ui.select = "ui.select"
---@module "willothy.modules.ui.code_actions"
willothy.ui.code_actions = "ui.code_actions"
---@module "willothy.modules.ui.foldtext"
willothy.ui.foldtext = "ui.foldtext"

willothy.hydras = module()
---@module "willothy.modules.hydras.git"
willothy.hydras.git = "hydras.git"
---@module "willothy.modules.hydras.options"
willothy.hydras.options = "hydras.options"
---@module "willothy.modules.hydras.telescope"
willothy.hydras.telescope = "hydras.telescope"
---@module "willothy.modules.hydras.diagrams"
willothy.hydras.diagrams = "hydras.diagrams"
---@module "willothy.modules.hydras.windows"
willothy.hydras.windows = "hydras.windows"
---@module "willothy.modules.hydras.buffers"
willothy.hydras.buffers = "hydras.buffers"
---@module "willothy.modules.hydras.swap"
willothy.hydras.swap = "hydras.swap"

require("willothy.settings")

return {
  setup = function()
    willothy.fs.hijack_netrw()

    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      once = true,
      callback = function()
        -- setup ui
        willothy.ui.setup()
        willothy.hydras.setup()

        -- Inform vim how to enable undercurl in wezterm
        vim.api.nvim_exec2(
          [[
                  let &t_Cs = "\e[4:3m"
                  let &t_Ce = "\e[4:0m"
              ]],
          {}
        )
      end,
    })
  end,
}
