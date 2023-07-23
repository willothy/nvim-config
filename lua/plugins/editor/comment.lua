local opt = {
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
}

return { {
  "numToStr/Comment.nvim",
  opts = opt,
  event = "VeryLazy",
} }
