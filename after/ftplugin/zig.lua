local bo = vim.bo
local wo = vim.wo

bo.tabstop = 4
bo.shiftwidth = 4
bo.softtabstop = -1
bo.expandtab = true
bo.smartindent = false

wo.wrap = false
wo.number = true
wo.relativenumber = true

vim.api.nvim_del_augroup_by_name("vim-zig")
