return {
  setup = function()
    require("willothy.ui.floats").setup()
    require("willothy.ui.modenr").setup()
    require("willothy.ui.scrollbar").setup({
      hl_group = {
        bar = "TabLineFill",
        thumb = "ScrollBar",
      },
    })
    require("willothy.ui.indentscope").setup()
  end,
}
