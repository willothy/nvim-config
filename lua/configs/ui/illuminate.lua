-- Highlight other uses of the word under the cursor. Prefers LSP
-- document-highlights (actual references), falling back to treesitter then
-- regex. Default highlight groups: IlluminatedWordText/Read/Write (underline).
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
