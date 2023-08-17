local keymap = willothy.keymap
-- selene: allow(unused_variable)
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

register({
  name = "jump",
  d = {
    function()
      require("configs.navigation.portal").diagnostics({
        buffer = vim.api.nvim_get_current_buf(),
      })
    end,
    "diagnostics",
  },
  r = {
    function()
      require("configs.navigation.portal").references()
    end,
    "references",
  },
  j = {
    function()
      require("portal.builtin").jumplist.tunnel()
    end,
    "jumplist",
  },
  h = {
    function()
      require("portal.builtin").harpoon.tunnel()
    end,
    "harpoon",
  },
  q = {
    function()
      require("portal.builtin").quickfix.tunnel()
    end,
    "quickfix",
  },
  c = {
    function()
      require("portal.builtin").changelist.tunnel()
    end,
    "changelist",
  },
}, modes.non_editing, "<leader>j")
