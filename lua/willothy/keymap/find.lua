local keymap = require("willothy.util.keymap")
local register, modes = keymap.register, keymap.modes

local telescope = require("willothy.util").telescope

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
  -- t = {
  --   telescope
  -- },
  P = {
    telescope.builtin,
    "telescope pickers",
  },
}, modes.non_editing, "<leader>f")
