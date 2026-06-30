
local bo = vim.bo
local wo = vim.wo

bo.tabstop = 2
bo.shiftwidth = 2
bo.softtabstop = -1
bo.expandtab = true
bo.smartindent = false

wo.wrap = false
wo.number = true
wo.relativenumber = true

require("willothy.actions").setup({
  run = function()
    return "node " .. vim.fn.fnameescape(vim.fn.expand("%:p"))
  end,
}, {
  cwd = function()
    return vim.fn.expand("%:p:h")
  end,
})
