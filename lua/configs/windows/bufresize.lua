require("bufresize").setup({
  register = {
    trigger_events = { "BufWinEnter", "WinEnter" },
  },
  resize = {
    trigger_events = { "VimResized" },
  },
})
