require("which-key").setup({
  plugins = {
    presets = {
      operators = true,
      windows = true,
      nav = true,
      z = true,
      g = true,
    },
  },
  operators = {
    gc = nil,
  },
  key_labels = {
    ["<space>"] = "SPC",
    ["<cr>"] = "RET",
    ["<tab>"] = "TAB",
  },
  window = {
    position = "botright",
    border = "single",
    winblend = 20,
  },
  layout = {
    height = { min = 4, max = 25 }, -- min and max height of the columns
    width = { min = 20, max = 50 }, -- min and max width of the columns
    spacing = 3, -- spacing between columns
    align = "left", -- align columns left, center or right
  },
  sort_by_description = true,
  -- custom_view = require("willothy.wk-view"),
})
