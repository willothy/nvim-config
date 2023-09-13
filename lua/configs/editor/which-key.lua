require("which-key").setup({
  plugins = {
    presets = {
      operators = false,
      windows = false,
      nav = true,
      z = true,
      g = false,
      text_objects = false,
    },
  },
  operators = {
    gc = "comment",
    v = "visual",
    [">"] = "indent",
    ["<lt>"] = "unindent",
    gu = "lowercase",
    gU = "uppercase",
    ["g~"] = "toggle case",
    ["!"] = "ext. filter",
    y = "yank",
    d = "delete",
    c = "change",
    ["="] = "indent",
  },
  motions = {
    count = true,
  },
  key_labels = {
    ["<space>"] = "SPC",
    ["<cr>"] = "RET",
    ["<tab>"] = "TAB",
  },
  window = {
    position = "bottom",
    border = "none",
    winblend = 0,
    margin = { 0, 0, 1, 0 },
    padding = { 0, 2, 1, 2 },
    zindex = 1000,
  },
  layout = {
    height = { min = 4, max = 20 }, -- min and max height of the columns
    width = { min = 20, max = 50 }, -- min and max width of the columns
    spacing = 3, -- spacing between columns
    align = "left", -- align columns left, center or right
  },
  icons = {
    group = "",
  },
  sort_by_description = true,
})
