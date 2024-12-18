require("crates").setup({
  completion = {
    cmp = {
      enabled = true,
    },
    crates = {
      enabled = true,
    },
  },
  -- lsp = {
  --   enabled = true,
  --   actions = true,
  --   completion = true,
  --   hover = true,
  -- },
  null_ls = {
    enabled = true,
    name = "crates.nvim",
  },
})

-- require("crates.completion.cmp").setup()

-- require("cmp").setup.buffer({ sources = { { name = "crates" } } })
