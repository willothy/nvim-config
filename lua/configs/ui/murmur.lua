vim.api.nvim_set_hl(0, "Cursorword", {})

require("murmur").setup({
  exclude_filetypes = {
    "neo-tree",
    "noice",
    "SidebarNvim",
    "terminal",
    "trouble",
  },
  cursor_rgb = "Cursorword",
  cursor_rgb_current = "Cursorword",
  cursor_rgb_always_use_config = true,
  -- murmur's yank-blink calls the deprecated vim.highlight.on_yank (warns on
  -- every yank on nightly); yanky already highlights yanks via the modern API.
  yank_blink = { enabled = false },
})
