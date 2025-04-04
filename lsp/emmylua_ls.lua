return {
  capabilties = require("willothy.lsp.capabilities").make_capabilities(),
  cmd = { "emmylua_ls" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    "luarc.json",
    ".git",
  },
  settings = {
    runtime = {
      version = "LuaJIT",
      -- requirePattern = { "lua/?.lua", "lua/?/init.lua" },
    },
    workspace = {
      library = vim.api.nvim_get_runtime_file("lua/*.lua", true),
    },
  },
}
