local bo = vim.bo
local wo = vim.wo

bo.tabstop = 4
bo.shiftwidth = 4
bo.softtabstop = -1
bo.expandtab = true
bo.smartindent = false

wo.wrap = false

local actions = require("willothy.actions")
actions.setup({
  run = "zig build run",
  build = "zig build",
}, { cwd = actions.root("build.zig") })
