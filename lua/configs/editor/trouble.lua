local trouble = require("trouble")

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
      statuscolumn = "%!v:lua.require('statuscol').get_statuscol_string()",
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
