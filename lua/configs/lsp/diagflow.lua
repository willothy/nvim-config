local opts = {
  placement = "top",
  scope = "line",
  show_sign = true,
  update_event = {
    "DiagnosticChanged",
    "BufReadPost",
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
}

require("diagflow").setup(opts)
