local bo = vim.bo
local wo = vim.wo

bo.tabstop = 2
bo.shiftwidth = 2
bo.softtabstop = -1
bo.expandtab = true
bo.smartindent = false

wo.wrap = false
vim.bo.syntax = "go"

require("willothy.actions").setup({
  run = "go run .",
  build = "go build",
}, {
  cwd = function()
    return vim.fn.expand("%:p:h")
  end,
})
