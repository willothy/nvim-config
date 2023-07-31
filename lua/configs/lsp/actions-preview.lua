require("actions-preview").setup({
  backend = { "nui" },
  nui = {
    -- component direction. "col" or "row"
    dir = "col",
    -- keymap for selection component: https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/menu#keymap
    keymap = nil,
    -- options for nui Layout component: https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/layout
    layout = {
      position = {
        row = 1,
        col = 1,
      },
      -- size = {
      --   width = "60%",
      --   height = "90%",
      -- },
      -- min_width = 40,
      -- min_height = 10,
      relative = "cursor",
    },
    preview = {
      size = "30%",
      border = {
        style = "rounded",
        padding = { 0, 0 },
      },
    },
    select = {
      size = "20%",
      border = {
        style = "rounded",
        padding = { 0, 0 },
      },
    },
  },
})
