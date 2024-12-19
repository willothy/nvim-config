local icons = willothy.ui.icons

local signs = {
  DapBreakpoint = {
    text = icons.dap.breakpoint.data,
    icon = icons.dap.breakpoint.data,
    texthl = "DiagnosticSignError",
  },
  DapBreakpointCondition = {
    text = icons.dap.breakpoint.conditional,
    icon = icons.dap.breakpoint.conditional,
    texthl = "DiagnosticSignWarn",
  },
  DapLogPoint = {
    text = icons.dap.breakpoint.log,
    icon = icons.dap.breakpoint.log,
    texthl = "DiagnosticSignInfo",
  },
  DapStopped = {
    text = icons.dap.action.stop,
    icon = icons.dap.action.stop,
    texthl = "DiagnosticSignInfo",
  },
  DapBreakpointRejected = {
    text = icons.dap.breakpoint.unsupported,
    icon = icons.dap.breakpoint.unsupported,
    texthl = "DiagnosticSignWarn",
  },
}

for name, def in pairs(signs) do
  vim.fn.sign_define(name, def)
end

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = true,
  underline = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
    },
  },
  float = {
    header = setmetatable({}, {
      __index = function(_, k)
        local arr = {
          string.format(
            "Diagnostics: %s %s",
            require("nvim-web-devicons").get_icon_by_filetype(vim.bo.filetype),
            vim.bo.filetype
          ),
          "Title",
        }
        return arr[k]
      end,
    }),
    source = true,
    border = "solid",
    focusable = false,
  },
})

local opts = {
  placement = "top",
  scope = "line",
  update_event = {
    "DiagnosticChanged",
    -- "BufReadPost",
    "TextChanged",
    "BufEnter",
  },
  render_event = {
    "DiagnosticChanged",
    "TextChanged",
    "CursorMoved",
    "CursorHold",
    "BufEnter",
  },
  format = function(diag)
    local levels = {
      [1] = "Error",
      [2] = "Warn",
      [3] = "Info",
      [4] = "Trace",
    }

    local icon = icons.diagnostics[levels[diag.severity]]

    return string.format(
      "%s%s%s",
      icon or "",
      icon and " " or "",
      diag.message or ""
    )
  end,
}

require("diagflow").setup(opts)
