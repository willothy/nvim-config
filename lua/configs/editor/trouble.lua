local icons = willothy.icons.diagnostics

local trouble = require("trouble")

trouble.setup({
  signs = {
    error = icons.error,
    warning = icons.warning,
    hint = icons.hint,
    information = icons.info,
  },
  fold_open = willothy.icons.fold.open,
  -- fold_closed = willothy.icons.fold.closed,
  fold_closed = "e",
  auto_open = false,
  auto_close = true,
  track_cursor = true,
  padding = false,
  indent_lines = false,
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
