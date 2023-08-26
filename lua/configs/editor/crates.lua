require("crates").setup({
  null_ls = {
    enabled = true,
    name = "crates.nvim",
  },
})
---@diagnostic disable-next-line: missing-fields
require("cmp").setup.buffer({ sources = { { name = "crates" } } })
