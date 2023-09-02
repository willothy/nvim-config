local keymap = willothy.keymap
-- selene: allow(unused_variable)
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

local cleanup

register({
  name = "lsp",
  a = {
    function()
      local curwin = vim.api.nvim_get_current_win()
      local group = require("rust-tools.code_action_group")
      if not cleanup then
        cleanup = group.cleanup
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      group.cleanup = function()
        cleanup()
        vim.api.nvim_set_current_win(curwin)
      end

      group.code_action_group()
      -- vim.lsp.buf.code_action()
      -- require("hollywood").code_actions()
    end,
    "code actions",
  },
  r = {
    vim.lsp.buf.references,
    "references",
  },
  d = {
    vim.lsp.buf.definition,
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
  n = {
    function()
      vim.api.nvim_feedkeys(
        ":IncRename " .. vim.fn.expand("<cword>"),
        "n",
        true
      )
    end,
  },
}, modes.non_editing, "<leader>c")
