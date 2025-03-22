local function reload_workspace(bufnr)
  local util = require("lspconfig.util")
  bufnr = util.validate_bufnr(bufnr)
  local clients =
    util.get_lsp_clients({ bufnr = bufnr, name = "rust_analyzer" })
  for _, client in ipairs(clients) do
    vim.notify("Reloading Cargo Workspace")
    client:request("rust-analyzer/reloadWorkspace", nil, function(err)
      if err then
        error(tostring(err))
      end
      vim.notify("Cargo workspace reloaded")
    end, 0)
  end
end

local function is_library(fname)
  local util = require("lspconfig.util")
  local user_home = vim.fs.normalize(vim.env.HOME)
  local cargo_home = os.getenv("CARGO_HOME") or user_home .. "/.cargo"
  local registry = cargo_home .. "/registry/src"
  local git_registry = cargo_home .. "/git/checkouts"

  local rustup_home = os.getenv("RUSTUP_HOME") or user_home .. "/.rustup"
  local toolchains = rustup_home .. "/toolchains"

  for _, item in ipairs({ toolchains, registry, git_registry }) do
    if util.path.is_descendant(item, fname) then
      local clients = util.get_lsp_clients({ name = "rust_analyzer" })
      return #clients > 0 and clients[#clients].config.root_dir or nil
    end
  end
end

return {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  single_file_support = true,
  root_markers = { "Cargo.lock", "Cargo.toml", ".git" },
  capabilities = {
    experimental = {
      serverStatusNotification = true,
    },
  },
  root_dir = function(bufnr, callback)
    coroutine.resume(coroutine.create(function()
      local fname = vim.api.nvim_buf_get_name(bufnr)

      local reuse_active = is_library(fname)
      if reuse_active then
        callback(reuse_active)
        return
      end

      local cargo_crate_dir =
        require("lspconfig.util").root_pattern("Cargo.toml")(fname)
      local cargo_workspace_root

      if cargo_crate_dir ~= nil then
        local cmd = {
          "cargo",
          "metadata",
          "--no-deps",
          "--format-version",
          "1",
          "--manifest-path",
          cargo_crate_dir .. "/Cargo.toml",
        }

        local result = require("lspconfig.async").run_command(cmd)

        if result and result[1] then
          result = vim.json.decode(table.concat(result, ""))
          if result["workspace_root"] then
            cargo_workspace_root = vim.fs.normalize(result["workspace_root"])
          end
        end
      end

      callback(
        cargo_workspace_root
          or cargo_crate_dir
          or require("lspconfig.util").root_pattern("rust-project.json")(fname)
          or vim.fs.dirname(
            vim.fs.find(".git", { path = fname, upward = true })[1]
          )
      )
    end))
  end,
  before_init = function(init_params, config)
    -- See https://github.com/rust-lang/rust-analyzer/blob/eb5da56d839ae0a9e9f50774fa3eb78eb0964550/docs/dev/lsp-extensions.md?plain=1#L26
    if config.settings and config.settings["rust-analyzer"] then
      init_params.initializationOptions = config.settings["rust-analyzer"]
    end
  end,
}
