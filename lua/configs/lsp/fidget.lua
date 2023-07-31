require("fidget").setup({
  text = {
    spinner = "pipe", --"dots",
    done = "✓",
    commenced = "+",
    completed = "✓",
  },
  fmt = {
    stack_upwards = false,
  },
  align = {
    bottom = false,
    right = true,
  },
  window = {
    blend = 0,
    relative = "editor",
  },
})
