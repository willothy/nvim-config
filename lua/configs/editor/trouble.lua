local icons = require("willothy.util.icons").diagnostics

require("trouble").setup({
  signs = {
    error = icons.error,
    warning = icons.warning,
    hint = icons.hint,
    information = icons.info,
  },
  auto_open = false,
  auto_close = true,
  track_cursor = true,
  padding = false,
})
