require("neogit").setup({
  kind = "auto",
  disable_builtin_notifications = true,
  integrations = {
    telescope = true,
    diffview = true,
  },
  log_view = {
    kind = "split",
  },
  reflog_view = {
    kind = "split",
  },
})
