local smart_splits = require("smart-splits")

smart_splits.setup({
  at_edge = "stop",
  resize_mode = {
    hooks = {
      on_leave = function(...)
        ---@diagnostic disable-next-line: redundant-parameter
        require("bufresize").register(...)
      end,
    },
  },
  ignore_events = {
    "WinResized",
    "BufWinEnter",
    "BufEnter",
    "WinEnter",
  },
})
