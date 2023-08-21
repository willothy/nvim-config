require("actions-preview").setup({
  backend = { "nui", "telescope" },
  nui = {
    dir = "col",
    keymap = nil,
    layout = {
      position = 1,
      size = {
        width = "40%",
        height = "40%",
      },
      min_width = 40,
      min_height = 10,
      relative = "cursor",
    },
    preview = {
      size = "70%",
      border = {
        style = "single",
        padding = { 0, 1 },
      },
    },
    select = {
      size = "30%",
      border = {
        style = "single",
        padding = { 0, 1 },
      },
    },
  },
})
