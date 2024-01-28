local telescope = willothy.fn.telescope

local hint = [[
_s_: live grep  _f_: find files
_g_: git files  _r_: resume
_p_: projects   _u_: edit hist.

_<Enter>_: pickers

_<Esc>_, _q_: close
]]

return require("hydra")({
  hint = hint,
  name = "Telescope",
  short_name = "T󰭎",
  config = {
    desc = "telescope",
    color = "blue",
    invoke_on_body = true,
    hint = {
      position = "bottom-left",
      border = "single",
    },
  },
  mode = "n",
  body = "<leader>vt",
  heads = {
    {
      "s",
      telescope("live_grep"),
      { desc = "live grep" },
    },
    {
      "f",
      telescope("find_files"),
      { desc = "find files" },
    },
    {
      "g",
      telescope("git_files"),
      { desc = "git files" },
    },
    { "r", telescope("resume"), { desc = "resume" } },
    {
      "p",
      telescope("projects"),
      { desc = "projects" },
    },
    {
      "u",
      telescope("undo"),
      { desc = "edit hist." },
    },
    {
      "<Enter>",
      telescope("builtin"),
      { desc = "pickers", ends = true },
    },
    {
      "<Esc>",
      nil,
      { exit = true, nowait = true, desc = "close" },
    },
    { "q", nil, { exit = true, nowait = true, desc = "close" } },
  },
})
