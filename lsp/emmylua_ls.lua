return {
  capabilties = require("willothy.lsp.capabilities").make_capabilities(),
  cmd = { "emmylua_ls" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    "luarc.json",
    ".git",
  },
  -- settings = {
  --   Lua = {
  --     diagnostics = {
  --       enable = true,
  --       unusedLocalExclude = {
  --         "_*",
  --       },
  --       globals = { "vim" },
  --     },
  --     completion = {
  --       autoRequire = true,
  --       callSnippet = "Disable",
  --       displayContext = 2,
  --     },
  --     format = {
  --       enable = true,
  --     },
  --     hint = {
  --       enable = true,
  --       setType = true,
  --       arrayIndex = "Disable",
  --       await = true,
  --       paramName = "All",
  --       paramType = true,
  --       semicolon = "SameLine",
  --     },
  --     runtime = {
  --       -- Tell the language server which version of Lua you're using
  --       -- (most likely LuaJIT in the case of Neovim)
  --       version = "LuaJIT",
  --     },
  --     -- Make the server aware of Neovim runtime files
  --     workspace = {
  --       checkThirdParty = false,
  --       -- library = vim
  --       --   .iter(
  --       --     {
  --       --       vim.env.VIMRUNTIME,
  --       --
  --       --       -- Depending on the usage, you might want to add additional paths here.
  --       --       "${3rd}/luv/library",
  --       --       -- "${3rd}/busted/library",
  --       --     }
  --       --     -- vim.api.nvim_get_runtime_file("lua/vim/*", true)
  --       --     -- vim.api.nvim_get_runtime_file("lua/vim/iter", true)
  --       --   )
  --       --   :flatten()
  --       --   :totable(),
  --       -- -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
  --       library = vim.api.nvim_get_runtime_file("", true),
  --       -- library = { "$VIMRUNTIME" },
  --     },
  --   },
  -- },
}
