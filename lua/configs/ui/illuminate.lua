-- Highlight other uses of the word under the cursor: LSP document-highlights
-- (actual references) first, then treesitter, then regex.
require("illuminate").configure({
  providers = {
    "lsp",
    "treesitter",
    "regex",
  },
  delay = 100,
  under_cursor = true,
  filetypes_denylist = {
    "neo-tree",
    "noice",
    "SidebarNvim",
    "terminal",
    "trouble",
  },
})
