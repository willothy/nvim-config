vim.lsp.config("*", {
  capabilities = require("willothy.lsp.capabilities").make_capabilities(),
})

require("mason").setup()

vim
  .iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
  :map(function(server_config_path)
    return vim.fs.basename(server_config_path):match("^(.*)%.lua$")
  end)
  :each(function(server_name)
    if server_name == "emmylua_ls" then
      return
    end
    vim.lsp.enable(server_name)
  end)
