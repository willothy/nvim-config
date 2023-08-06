local keymap = require("willothy.util.keymap")
-- selene: allow(unused_variable)
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

register({
  a = {
    function()
      require("hollywood").code_actions()
    end,
    "code actions",
  },
  r = {
    function()
      require("glance").open("references")
    end,
    "references",
  },
  d = {
    function()
      require("glance").open("definitions")
    end,
    "definitions",
  },
  D = {
    vim.lsp.buf.declaration,
    "declaration",
  },
  T = {
    function()
      require("glance").open("type_definitions")
    end,
    "type definition",
  },
  i = {
    function()
      require("glance").open("implementations")
    end,
    "implementations",
  },
}, modes.non_editing, "<leader>c")
