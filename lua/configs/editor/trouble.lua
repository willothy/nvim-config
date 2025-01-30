local trouble = require("trouble")

---@diagnostic disable-next-line: missing-fields
trouble.setup({
  pinned = true,
  focus = true,
  follow = false,
  restore = true,
  win = {
    type = "split",
    wo = {
      fillchars = vim.o.fillchars,
      cursorlineopt = "number",
      concealcursor = "nvic",
    },
  },
  indent_guides = true,
  multiline = true,
  preview = {
    type = "main",
    zindex = 50,
    wo = {
      -- winbar = "",
      -- statuscolumn = "%!v:lua.StatusCol()",
      -- statuscolumn = "%!v:lua.require('statuscol').get_statuscol_string()",
      list = true,
      number = true,
      relativenumber = false,
    },
  },
  modes = {
    definitions2 = {
      mode = "lsp_definitions",
      focus = true,
      sections = {
        ["lsp_definitions"] = {
          title = "LSP Definitions",
          icon = "",
          highlight = "TroubleLspDef",
          indent = 1,
        },
      },
    },
  },
})

vim.api.nvim_set_hl(0, "TroubleNormalNC", {
  link = "TroubleNormal",
})

for nvim_name, trouble_name in pairs({
  references = "lsp_references",
  definition = "lsp_definitions",
  type_definition = "lsp_type_definitions",
  implementation = "lsp_implementations",
  document_symbol = "lsp_document_symbols",
}) do
  vim.lsp.buf[nvim_name] = function()
    require("trouble").open({
      mode = trouble_name,
    })
  end
end
