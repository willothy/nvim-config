local icons = willothy.icons.diagnostics

local trouble = require("trouble")

trouble.setup({
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

local view = require("trouble.view")
local update = view.update
local create = view.create
view.update = function(self, opts)
  update(self, opts)
  vim.b[self.buf].trouble_mode = opts.mode
end
view.create = function(opts)
  local buf = create(opts)
  vim.b[buf.buf].trouble_mode = opts.mode
  return buf
end
