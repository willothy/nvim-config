local keymap = willothy.keymap
-- selene: allow(unused_variable)
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

register({
  name = "lsp",
  a = bind(vim.lsp.buf.code_action):with_desc("code actions"),
  r = bind(vim.lsp.buf.references):with_desc("references"),
  d = bind(vim.lsp.buf.definition):with_desc("definitions"),
  D = bind(vim.lsp.buf.declaration):with_desc("declarations"),
  T = bind(vim.lsp.buf.type_definition):with_desc("type definitions"),
  i = bind(vim.lsp.buf.implementation):with_desc("implementations"),
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
