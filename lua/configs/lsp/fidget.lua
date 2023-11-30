require("fidget").setup({
  progress = {
    display = {
      overrides = {
        rust_analyzer = { name = "rust-analyzer" },
        lua_ls = { name = "lua-ls" },
      },
    },
  },
})
