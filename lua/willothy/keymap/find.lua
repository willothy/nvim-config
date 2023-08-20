local keymap = willothy.keymap
local register, modes = keymap.register, keymap.modes

local telescope = willothy.fn.telescope

register({
  name = "find",
  f = {
    telescope.find_files,
    "files",
  },
  s = {
    telescope.live_grep,
    "live grep",
  },
  g = {
    telescope.git_files,
    "git files",
  },
  p = {
    telescope.projects,
    "projects",
  },
  u = {
    telescope.undo,
    "undo history",
  },
  o = { telescope.oldfiles, "oldfiles" },
  r = {
    telescope.registers,
    "registers",
  },
  l = {
    telescope.lsp_document_symbols,
    "document symbols",
  },
  -- t = {
  --   telescope
  -- },
  P = {
    telescope.builtin,
    "telescope pickers",
  },
}, modes.non_editing, "<leader>f")
