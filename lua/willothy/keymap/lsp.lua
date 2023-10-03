local keymap = willothy.keymap
-- selene: allow(unused_variable)
local bind, modes = keymap.bind, keymap.modes

local wk = require("which-key")

wk.register({
  name = "lsp",
  a = bind(vim.lsp.buf.code_action):with_desc("code actions"),
  r = bind(vim.lsp.buf.references):with_desc("references"),
  d = bind(vim.lsp.buf.definition):with_desc("definitions"),
  D = bind(vim.lsp.buf.declaration):with_desc("declarations"),
  T = bind(vim.lsp.buf.type_definition):with_desc("type definitions"),
  i = bind(vim.lsp.buf.implementation):with_desc("implementations"),
  h = bind(vim.lsp.buf.signature_help):with_desc("signature help"),
  O = bind(vim.lsp.buf.outgoing_calls):with_desc("outgoing calls"),
  I = bind(vim.lsp.buf.incoming_calls):with_desc("incoming calls"),
  n = {
    function()
      vim.api.nvim_feedkeys(
        ":IncRename " .. vim.fn.expand("<cword>"),
        "n",
        true
      )
    end,
    "rename",
  },
}, { mode = modes.non_editing, prefix = "<leader>c" })

wk.register({
  ["<S-Esc>"] = {
    bind("trouble", "toggle", "document_diagnostics"),
    "diagnostics",
  },
  K = bind("rust-tools.hover_actions", "hover_actions"):with_desc(
    "lsp: hover"
  ),
}, { mode = modes.non_editing })
