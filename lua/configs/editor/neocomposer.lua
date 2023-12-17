local opts = {
  window = {
    border = "solid",
    winhl = {
      Normal = "NormalFloat",
      FloatBorder = "FloatBorder",
      FloatTitle = "FloatTitle",
    },
  },
  colors = {
    bg = "#26283f",
  },
  keymaps = {
    toggle_record = "q", -- for some reason this is required even if I map the key myself later?
    play_macro = false,
    yank_macro = false,
    stop_macro = false,
    cycle_next = false,
    cycle_prev = false,
    toggle_macro_menu = false,
  },
}

require("NeoComposer").setup(opts)
