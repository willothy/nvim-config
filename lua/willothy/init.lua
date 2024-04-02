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

willothy = metamodule("willothy", {
  ui = metamodule("willothy.ui"),
  utils = metamodule("willothy.utils"),
  async = module("nio", "willothy", "async"),
})

-- TODO: Modules should just load automatically,
-- TODO: I want to organize this whole config better.
--
-- WIP
--
-- My idea is a structure like this:
--
-- .config/nvim/
-- ├── lua/
-- │   ├── willothy/ # exposed as global 'willothy'
-- │   │   ├── ui/
-- │   │   │   ├── status/
-- │   │   │   │   ├── statusline.lua # heirline config
-- │   │   │   │   ├── statuscol.lua  # statuscol config
-- │   │   │   │   ├── tabline.lua    # cokeline config
-- │   │   │   │   └── winbar.lua     # dropbar config
-- │   │   │   ├── fold/
-- │   │   │   │   ├── text.lua
-- │   │   │   │   └── expr.lua
-- │   │   │   ├── scroll/
-- │   │   │   │   ├── scrollbar.lua
-- │   │   │   │   └── scrolleof.lua
-- │   │   │   ├── code_actions.lua
-- │   │   │   ├── float_drag.lua
-- │   │   │   ├── intro.lua
-- │   │   │   ├── player.lua
-- │   │   │   ├── icons.lua
-- │   │   │   ├── cursor.lua
-- │   │   │   └── mode.lua
-- │   │   ├── utils/
-- │   │   │   ├── debug.lua
-- │   │   │   └── plugins.lua
-- │   │   ├── fn/ (todo: split fn.lua into multiple files)
-- │   │   │   └── ...
-- │   │   ├── hydras/ (todo: make hydras fully lazy)
-- │   │   │   └── ...
-- │   │   ├── fs.lua       # filesystem utils
-- │   │   ├── hl.lua       # highlighting
-- │   │   ├── keymap.lua   # keymap utils
-- │   │   ├── terminal.lua # terminals
-- │   │   ├── event.lua    # autocmd and event utils
-- │   │   ├── win.lua      # window utils
-- │   │   ├── buf.lua      # buffer utils
-- │   │   ├── tab.lua      # tabpage utils
-- │   │   ├── str.lua      # string lib
-- │   │   └── graphql.lua  # integrate my Lua graphql client

return {
  setup = function()
    vim.api.nvim_create_autocmd("UiEnter", {
      once = true,
      callback = function()
        -- setup ui
        willothy.ui.scrollbar.setup()
        willothy.ui.scrolleof.setup()
        willothy.ui.float_drag.setup()
        willothy.ui.code_actions.setup()
        willothy.ui.mode.setup()
        willothy.ui.colors.setup()
      end,
    })

    require("willothy.fs").hijack_netrw()
  end,
}
