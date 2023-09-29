local keymap = willothy.keymap
local register, modes = keymap.register, keymap.modes

local telescope = willothy.fn.telescope

register({
  name = "find",
  f = {
    function()
      require("telescope._extensions.frecency").exports.frecency({
        show_filter_column = { "LSP", "CWD", "projects" },
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
}, modes.non_editing, "<leader>f")
