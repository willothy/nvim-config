local function trim(str)
  return str:gsub("^%s+", ""):gsub("%s+$", "")
end
vim.system(
  { "lpass", "show", "--field", "Key", "Sourcegraph" },
  { text = true },
  vim.schedule_wrap(function(obj)
    local status, out, err = obj.code, obj.stdout, obj.stderr

    if status ~= 0 then
      vim.api.nvim_err_writeln(("Sourcegraph: %s"):format(err))
      return
    end

    require("sg").setup({
      on_attach = require("configs.lsp").lsp_attach,
      auth_strategy = { "nvim", "environment-variables" },
      download_binaries = false,
    })
    require("sg.auth").set_nvim_auth({
      endpoint = "https://sourcegraph.com/",
      token = trim(out),
    })
  end)
)
