local glance = require("glance")

glance.setup({
  height = 18,
  zindex = 45,
  detached = function(winid)
    return vim.api.nvim_win_get_width(winid) < 100
  end,
  preview_win_opts = {
    cursorline = true,
    number = true,
    wrap = false,
  },
  border = {
    enable = true,
    top_char = "‾",
    bottom_char = "‾",
  },
  list = {
    position = "right",
    width = 0.33,
  },
  hooks = {},
})
