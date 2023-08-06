require("fidget").setup({
  text = {
    spinner = "pipe",
    done = "✓",
    commenced = "+",
    completed = "✓",
  },
  fmt = {
    stack_upwards = true,
  },
  align = {
    bottom = true,
    right = true,
  },
  window = {
    blend = 0,
    relative = "editor",
  },
})
