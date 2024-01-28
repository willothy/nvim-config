local icons = willothy.ui.icons

local opts = {
  placement = "top",
  scope = "line",
  -- scope = "node",
  show_sign = true,
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

    local icon = icons.diagnostics[levels[diag.severity]] or ""
    local space = icon == "" and "" or " "

    return icon .. space .. diag.message
  end,
}

require("diagflow").setup(opts)
