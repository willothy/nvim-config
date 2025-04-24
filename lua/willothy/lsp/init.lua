vim.lsp.config("*", {
  capabilities = require("willothy.lsp.capabilities").make_capabilities(),
})

require("mason").setup()

local disabled = {
  emmylua_ls = true,
  -- lua_ls = true,
}

local configured = {
  "basedpyright",
  "bashls",
  "biome",
  "bufls",
  "clangd",
  "cmake",
  "dockerls",
  "emmylua_ls",
  "eslint",
  "gleam",
  "gopls",
  "intelephense",
  "jsonls",
  "lua_ls",
  "prismals",
  "rust_analyzer",
  "tailwindcss",
  "taplo",
  "ts_ls",
  "zls",
}

local function init()
  vim
    .iter(configured)
    -- :map(function(server_config_path)
    --   return vim.fs.basename(server_config_path):match("^(.*)%.lua$")
    -- end)
    :each(
      function(server_name)
        if disabled[server_name] then
          return
        end
        vim.lsp.enable(server_name)
      end
    )
end

if vim.g.did_very_lazy then
  vim.schedule(function()
    init(v)
  end)
else
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = vim.schedule_wrap(function()
      init()
    end),
  })
end
