require("nxwm").setup({
  unfocus_map = "<D-Esc>",
  on_win_get_conf = function(conf, xwin)
    return conf
  end,
})
