local keymap = require("willothy.util.keymap")
-- selene: allow(unused_variable)
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

local cleanup

register({
  name = "lsp",
  a = {
    function()
      local curwin = vim.api.nvim_get_current_win()
      local group = require("rust-tools.code_action_group")
      if not cleanup then cleanup = group.cleanup end

      group.cleanup = function()
        cleanup()
        vim.api.nvim_set_current_win(curwin)
      end

      group.code_action_group()
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
