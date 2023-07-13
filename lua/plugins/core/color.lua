return {
  -- Color themes
  {
    "rktjmp/lush.nvim",
    cond = true,
  },
  {
    "willothy/minimus",
    dir = "~/projects/lua/minimus/",
    dependencies = {
      "rktjmp/lush.nvim",
    },
    lazy = false,
  },
}
