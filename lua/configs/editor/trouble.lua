local icons = require("willothy.icons").diagnostics

require("trouble").setup({
  signs = {
    error = icons.error,
    warning = icons.warning,
    hint = icons.hint,
    information = icons.info,
  },
  track_cursor = true,
  padding = false,
})
