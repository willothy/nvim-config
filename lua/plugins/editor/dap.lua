local function setup()
  local dap = require("dap")

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

  local launchers = {
    lua = function()
      require("osv").run_this()
      -- require("osv").launch({ port = 8086 })
    end,
  }

  vim.keymap.set(
    "n",
    "<F8>",
    function() require("dap").toggle_breakpoint() end,
    { noremap = true, desc = "toggle breakpoint" }
  )
  vim.keymap.set(
    "n",
    "<F9>",
    function() require("dap").continue() end,
    { noremap = true, desc = "continue" }
  )
  vim.keymap.set(
    "n",
    "<F10>",
    function() require("dap").step_over() end,
    { noremap = true, desc = "step over" }
  )
  vim.keymap.set(
    "n",
    "<S-F10>",
    function() require("dap").step_into() end,
    { noremap = true, desc = "step into" }
  )
  vim.keymap.set(
    "n",
    "<F12>",
    function() require("dap.ui.widgets").hover() end,
    { noremap = true, desc = "dap hover" }
  )
  vim.keymap.set("n", "<F5>", function()
    local filetype = vim.bo.filetype
    local launch = launchers[filetype]
    if launch then
      local ok, res = pcall(launch)
      if ok then
        require("dapui").open()
      else
        vim.notify(
          ("Failed to start debugger for %s: %s"):format(filetype, res),
          "error"
        )
      end
    else
      vim.notify(("No debugger available for %s"):format(filetype), "warn")
    end
  end, { noremap = true, desc = "launch debugger" })
end

return {
  -- Core DAP plugins
  {
    "mfussenegger/nvim-dap",
    config = setup,
    event = "LspAttach",
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = true,
  },
  -- Individual debugger plugins
  {
    "jbyuki/one-small-step-for-vimkind",
  },
}
