require("smart-splits").setup({
  at_edge = "wrap",
  resize_mode = {
    hooks = {
      on_leave = require("bufresize").register,
    },
  },
  ignore_events = {
    "WinResized",
    "BufWinEnter",
    "BufEnter",
    "WinEnter",
  },
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("willothy/smart-splits", {}),
  callback = function()
    require("wezterm").set_user_var("IS_NVIM", false)
  end,
})
