local icons = willothy.ui.icons

local trouble = require("trouble")

trouble.setup({
  signs = {
    error = icons.diagnostics.error,
    warning = icons.diagnostics.warning,
    hint = icons.diagnostics.hint,
    information = icons.diagnostics.info,
  },
  fold_open = icons.fold.open,
  fold_closed = icons.fold.closed,
  auto_open = false,
  auto_close = false,
  track_cursor = true,
  padding = false,
  use_diagnostic_signs = true,
})

local view = require("trouble.view")
local update = view.update
view.update = function(self, opts)
  update(self, opts)
  if opts and opts.mode then
    vim.b[self.buf].trouble_mode = opts.mode
  end
end
