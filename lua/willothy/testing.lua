---@diagnostic disable-next-line: missing-fields
require("neotest").setup({
  adapters = {
    require("neotest-rust"),
    -- require("neotest-plenary"),
  },
  consumers = {
    ---@diagnostic disable-next-line: assign-type-mismatch
    overseer = require("neotest.consumers.overseer"),
  },
  ---@diagnostic disable-next-line: missing-fields
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
