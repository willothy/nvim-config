local keymap = willothy.map
local modes = keymap.modes

local telescope = willothy.fn.telescope

local wk = require("which-key")

wk.register({
  name = "find",
  f = {
    function()
      require("telescope").extensions.frecency.frecency({
        sorter = require("telescope").extensions.fzf.native_fzf_sorter(),
      })
    end,
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
}, { mode = modes.non_editing, prefix = "<leader>f" })
