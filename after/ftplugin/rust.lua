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

local actions = require("willothy.actions")
actions.setup({
  run = "cargo run",
  build = "cargo build",
  test = true,
}, { cwd = actions.root("Cargo.toml") })
