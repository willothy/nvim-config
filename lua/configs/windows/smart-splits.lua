require("smart-splits").setup({
  at_edge = "wrap",
  resize_mode = {
    hooks = {
      -- on_leave = require("bufresize").register,
    },
  },
  ignore_events = {
    "WinResized",
    "BufWinEnter",
    "BufEnter",
    "WinEnter",
  },
})
