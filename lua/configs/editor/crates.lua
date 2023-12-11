require("crates").setup({
  src = {
    cmp = {
      enabled = true,
    },
  },
  null_ls = {
    enabled = true,
    name = "crates.nvim",
  },
})

-- require("creates.src.cmp").setup()

require("cmp").setup.buffer({ sources = { { name = "crates" } } })
