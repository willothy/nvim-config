vim.lsp.config("*", {
  capabilities = require("willothy.lsp.capabilities").make_capabilities(),
})

require("mason").setup()

local disabled = {
  emmylua_ls = true,
  -- lua_ls = true,
}

local function init()
  vim
    .iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
    :map(function(server_config_path)
      return vim.fs.basename(server_config_path):match("^(.*)%.lua$")
    end)
    :each(function(server_name)
      if disabled[server_name] then
        return
      end
      vim.lsp.enable(server_name)
    end)
end

if vim.g.did_very_lazy then
  vim.schedule(function()
    init()
  end)
else
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = vim.schedule_wrap(function()
      init()
    end),
  })
end
