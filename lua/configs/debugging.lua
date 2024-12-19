local dap = require("dap")
require("overseer").enable_dap(true)

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
    ---@diagnostic disable-next-line: undefined-field
    host = config.host or "127.0.0.1",
    ---@diagnostic disable-next-line: undefined-field
    port = config.port or 8086,
  })
end

require("dapui").setup({
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
})

-- local M = {}
--
-- M.launchers = {
--   lua = function()
--     require("osv").run_this()
--   end,
-- }
--
-- function M.launch()
--   local filetype = vim.bo.filetype
--   local launch = require("configs.debugging").launchers[filetype]
--   if launch then
--     local ok, res = pcall(launch)
--     if not ok then
--       vim.notify(
--         ("Failed to start debugger for %s: %s"):format(filetype, res),
--         "error"
--       )
--     end
--   else
--     vim.notify(("No debugger available for %s"):format(filetype), "warn")
--   end
-- end
--
-- function M.is_active()
--   return require("dap").session() ~= nil
-- end
--
-- return M
