local keymap = willothy.keymap
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

local legendary = function(filter)
  return function()
    local f = require("legendary.filters")
    require("legendary").find({ filters = { f[filter]() } })
  end
end

---@type CodyLayoutSplit
local cody

register({
  name = "view",
  q = bind("trouble", "open", "quickfix"):with_desc("trouble: quickfix"),
  l = bind("trouble", "open", "loclist"):with_desc("trouble: loclist"),
  d = bind("dapui", "toggle"):with_desc("dap-ui"),
  c = {
    function()
      if not cody then
        local CodySplit = require("sg.components.layout.split")
        cody = CodySplit:init({
          name = "main",
        })
      end
      cody:toggle()
    end,
    "cody chat",
  },
  u = { vim.cmd.UndotreeToggle, "undotree" },
  L = {
    name = "legendary",
    k = {
      legendary("keymaps"),
      "keymaps",
    },
    a = {
      legendary("autocmds"),
      "autocmds",
    },
    c = {
      legendary("commands"),
      "commands",
    },
    f = {
      legendary("funcs"),
      "functions",
    },
  },
}, modes.non_editing, "<leader>v")
