require("window-picker").setup({
  show_prompt = false,
  hint = "floating-big-letter",
  filter_rules = {
    autoselect_one = false,
    include_current_win = false,
    bo = {
      filetype = {
        "noice",
      },
      buftype = {
        "nofile",
        "nowrite",
      },
    },
  },
  selection_chars = "asdfwertzxcv",
  create_chars = "hjkl",
  picker_config = {
    floating_big_letter = {
      font = {
        -- pick chars
        w = "w",
        a = "a",
        s = "s",
        d = "d",
        f = "f",
        e = "e",
        r = "r",
        t = "t",
        z = "z",
        x = "x",
        c = "c",
        v = "v",
        -- create chars
        h = "h",
        j = "j",
        k = "k",
        l = "l",
      },
      window = {
        config = {
          border = "none",
        },
        options = {
          winhighlight = "NormalFloat:TabLineSel,FloatBorder:TabLineSel",
        },
      },
    },
  },
})
