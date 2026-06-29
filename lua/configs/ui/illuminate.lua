-- Highlight other uses of the word under the cursor. Uses treesitter first
-- (synchronous, so highlights re-apply instantly), falling back to LSP then
-- regex. Default highlight groups: IlluminatedWordText/Read/Write (underline).
--
-- illuminate clears highlights immediately when the cursor moves to a new word
-- and only re-applies them after `delay` ms (and, for the async LSP provider,
-- after the server responds). A non-zero delay or an LSP-first order therefore
-- shows a blank gap = flicker. treesitter-first + delay 0 removes it.
require("illuminate").configure({
  providers = {
    "treesitter",
    "lsp",
    "regex",
  },
  delay = 0,
  under_cursor = true,
  filetypes_denylist = {
    "neo-tree",
    "noice",
    "SidebarNvim",
    "terminal",
    "trouble",
  },
})
