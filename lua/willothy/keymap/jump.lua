local keymap = willothy.map
-- selene: allow(unused_variable)
local bind, modes = keymap.bind, keymap.modes

local wk = require("which-key")

wk.register({
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
}, { mode = modes.non_editing, prefix = "<leader>j" })
