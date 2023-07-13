return {
  {
    "echasnovski/mini.indentscope",
    name = "mini.indentscope",
    lazy = true,
    -- enabled = false,
    event = "VeryLazy",
    config = function()
      require("mini.indentscope").setup({
        symbol = "▏",
        options = {
          -- border = "bottom",
          try_as_border = true,
        },
      })
    end,
  },
  {
    "echasnovski/mini.cursorword",
    name = "mini.cursorword",
    lazy = true,
    event = "VeryLazy",
    config = function() require("mini.cursorword").setup() end,
  },
}
