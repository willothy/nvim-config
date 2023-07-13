local opt = {
  toggler = { -- Normal Mode
    line = "<leader>cc",
    block = "<leader>cb",
  },
  opleader = { -- Visual Mode
    block = "<leader>c",
    line = "<leader>C",
  },
  extra = {
    eol = "<leader>l$",
  },
}

return { {
  "numToStr/Comment.nvim",
  opts = opt,
  event = "VeryLazy",
} }
