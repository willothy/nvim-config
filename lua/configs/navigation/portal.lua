require("portal").setup({
  labels = { "w", "a", "s", "d" },
  escape = {
    ["<esc>"] = true,
    q = true,
    -- Close on any cursor moving event
    h = true,
    j = true,
    k = true,
    l = true,
    ["<left>"] = true,
    ["<right>"] = true,
    ["<up>"] = true,
    ["<down>"] = true,
  },
  window_options = {
    border = "rounded",
  },
})
