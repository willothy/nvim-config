local dap = require("dap")
require("overseer").patch_dap(true)

dap.listeners.after.event_initialized["dapui_config"] = function()
  require("dapui").open()
  require("nvim-dap-virtual-text").refresh()
end
dap.listeners.after.disconnect["dapui_config"] = function()
  require("dap.repl").close()
  require("dapui").close()
  require("nvim-dap-virtual-text").refresh()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  require("dapui").close()
  require("nvim-dap-virtual-text").refresh()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  require("dapui").close()
  require("nvim-dap-virtual-text").refresh()
end

dap.configurations.rust = {
  {
    name = "Launch",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input(
        "Path to executable: ",
        vim.fn.getcwd() .. "/",
        "file"
      )
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
  },
}
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = "/home/willothy/.local/share/nvim/mason/bin/codelldb",
    args = { "--port", "${port}" },
  },
}

dap.configurations.lua = {
  {
    type = "nlua",
    request = "attach",
    name = "Attach to running Neovim instance",
  },
}

dap.adapters.nlua = function(callback, config)
  callback({
    type = "server",
    host = config.host or "127.0.0.1",
    port = config.port or 8086,
  })
end
