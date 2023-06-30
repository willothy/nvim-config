return {
  {
    "willothy/luahint",
    build = "cargo install --path=./",
    lazy = false,
    enabled = false,
    opts = {
      enabled_at_startup = true,
    },
    -- dir = "~/projects/rust/luahint/",
  },
}
