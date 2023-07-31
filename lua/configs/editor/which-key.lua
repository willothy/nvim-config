vim.o.timeout = true
vim.o.timeoutlen = 300
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
    -- position = "top",
    winblend = 20,
  },
  sort_by_description = true,
})
