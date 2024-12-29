vim.lsp.config.lua_ls = {
  settings = {
    Lua = {
      diagnostics = {
        enable = true,
        unusedLocalExclude = {
          "_*",
        },
        globals = { "vim", "willothy" },
      },
      completion = {
        autoRequire = true,
        callSnippet = "Disable",
        displayContext = 2,
      },
      format = {
        enable = true,
      },
      hint = {
        enable = true,
        setType = true,
        arrayIndex = "Disable",
        await = true,
        paramName = "All",
        paramType = true,
        semicolon = "SameLine",
      },
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = vim.list_extend({
          vim.env.VIMRUNTIME,

          -- Depending on the usage, you might want to add additional paths here.
          "${3rd}/luv/library",
          -- "${3rd}/busted/library",
        }, vim.api.nvim_get_runtime_file("lua/vim/*", true)),
        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
        -- library = vim.api.nvim_get_runtime_file("", true),
      },
    },
  },
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    "luarc.json",
    ".git",
  },
  -- on_init = function(client)
  --   -- if client.workspace_folders then
  --   --   local path = client.workspace_folders[1].name
  --   --   if
  --   --     vim.uv.fs_stat(path .. "/.luarc.json")
  --   --     or vim.uv.fs_stat(path .. "/.luarc.jsonc")
  --   --   then
  --   --     return
  --   --   end
  --   -- end
  --
  --   client.config.settings.Lua = vim.tbl_deep_extend(
  --     "force",
  --     client.config.settings.Lua or {} --[[@as table]],
  --     {
  --       runtime = {
  --         -- Tell the language server which version of Lua you're using
  --         -- (most likely LuaJIT in the case of Neovim)
  --         version = "LuaJIT",
  --       },
  --       -- Make the server aware of Neovim runtime files
  --       workspace = {
  --         checkThirdParty = false,
  --         library = vim.list_extend({
  --           vim.env.VIMRUNTIME,
  --
  --           -- Depending on the usage, you might want to add additional paths here.
  --           "${3rd}/luv/library",
  --           -- "${3rd}/busted/library",
  --         }, {}), --vim.api.nvim_get_runtime_file("lua/vim/*", true)),
  --         -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
  --         -- library = vim.api.nvim_get_runtime_file("", true)
  --       },
  --     }
  --   )
  -- end,
}
