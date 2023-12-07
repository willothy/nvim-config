require("yanky").setup({
  ring = {
    storage = "sqlite",
  },
  highlight = {
    on_put = true,
    on_yank = true,
    timer = 500,
  },
})
