local icons = willothy.ui.icons

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
