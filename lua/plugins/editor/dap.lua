local function setup()
  local dap = require("dap")

  dap.listeners.after.event_initialized["dapui_config"] = function()
    require("dapui").open()
  end
  dap.listeners.after.disconnect["dapui_config"] = function()
    require("dap.repl").close()
    require("dapui").close()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    require("dapui").close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    require("dapui").close()
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
  vim.keymap.set(
    "n",
    "<F5>",
    function() require("willothy.dap").launch() end,
    { noremap = true, desc = "launch debugger" }
  )
end

return {
  -- Core DAP plugins
  {
    "mfussenegger/nvim-dap",
    config = setup,
    event = "LspAttach",
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      clear_on_continue = true,
    },
    event = "User ExtraLazy",
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    opts = {
      icons = { expanded = "", collapsed = "", current_frame = "" },
      mappings = {
        -- Use a table to apply multiple mappings
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
      element_mappings = {},
      expand_lines = vim.fn.has("nvim-0.7") == 1,
      force_buffers = true,
      layouts = {
        {
          -- You can change the order of elements in the sidebar
          elements = {
            -- Provide IDs as strings or tables with "id" and "size" keys
            {
              id = "scopes",
              size = 0.25, -- Can be float or integer > 1
            },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 0.2,
          position = "left", -- Can be "left" or "right"
        },
        {
          elements = {
            "repl",
            "console",
          },
          size = 0.25,
          position = "bottom", -- Can be "bottom" or "top"
        },
      },
      floating = {
        max_height = nil,
        max_width = nil,
        border = "single",
        mappings = {
          ["close"] = { "q", "<Esc>" },
        },
      },
      controls = {
        enabled = true,
        element = "repl",
        icons = {
          pause = "",
          play = "",
          step_into = "",
          step_over = "",
          step_out = "",
          step_back = "",
          run_last = "",
          terminate = "",
          disconnect = "",
        },
      },
      render = {
        max_type_length = nil, -- Can be integer or nil.
        max_value_lines = 100, -- Can be integer or nil.
        indent = 1,
      },
    },
  },
  -- Individual debugger plugins
  {
    "jbyuki/one-small-step-for-vimkind",
  },
}
