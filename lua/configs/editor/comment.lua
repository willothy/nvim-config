require("Comment").setup({
  toggler = { -- Normal Mode
    line = "gbc",
    block = "gbb",
  },
  opleader = { -- Visual mode
    block = "gbc",
    line = "gcc",
  },
  extra = {
    eol = "gc$",
  },
})
