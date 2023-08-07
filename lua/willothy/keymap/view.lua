local keymap = require("willothy.util.keymap")
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

local legendary = function(filter)
  return function()
    local f = require("legendary.filters")
    require("legendary").find({ filters = { f[filter]() } })
  end
end
register({
  name = "view",
  o = {
    bind("telescope.builtin", "oldfiles"),
    "oldfiles",
  },
  r = {
    bind("telescope.builtin", "registers"),
    "registers",
  },
  s = {
    bind("telescope.builtin", "lsp_document_symbols"),
    "document symbols",
  },
  q = {
    bind("trouble", "open", "quickfix"),
    "quickfix",
  },
  l = {
    bind("trouble", "open", "loclist"),
    "loclist",
  },
  d = {
    bind("dapui", "toggle"),
    "dap ui",
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
