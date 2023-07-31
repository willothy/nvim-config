require("neotest").setup({
  adapters = {
    require("neotest-rust"),
  },
  summary = {
    enabled = true,
    animated = true,
  },
  diagnostic = {
    enabled = true,
    severity = vim.diagnostic.severity.ERROR,
  },
  status = {
    enabled = true,
    virtual_text = true,
    signs = true,
  },
})
