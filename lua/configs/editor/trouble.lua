local icons = willothy.ui.icons

local trouble = require("trouble")

trouble.setup({
  pinned = false,
  focus = false,
  follow = true,
  results = {
    win = {
      type = "split",
      wo = {
        fillchars = vim.o.fillchars,
      },
    },
    indent_guides = true,
    multiline = true,
  },
  preview = {
    win = {
      type = "main",
      wo = {
        winbar = "",
        statuscolumn = "%!v:lua.StatusCol()",
        list = true,
        number = true,
        relativenumber = false,
      },
    },
  },
})
