vim.lsp.config("*", {
  ---@diagnostic disable-next-line: param-type-mismatch
  capabilities = require("willothy.lsp.capabilities").make_capabilities(),
})

vim.lsp.set_log_level(vim.log.levels.OFF)

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
  "postgres_lsp", -- supabase-community/postgres-language-server
  "protols",
}

local function init()
  vim.iter(configured):each(vim.schedule_wrap(function(server_name)
    if disabled[server_name] then
      return
    end
    vim.lsp.enable(server_name)
  end))
end

if vim.g.did_very_lazy ~= nil then
  vim.schedule(init)
else
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = vim.schedule_wrap(init),
  })
end
