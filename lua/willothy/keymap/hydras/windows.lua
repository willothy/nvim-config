local pcmd = require("hydra.keymap-util").pcmd
local cmd = require("hydra.keymap-util").cmd

local window_hint = [[
 ^^^^^^^^^^^^     Move      ^^    Size   ^^   ^^     Split
 ^^^^^^^^^^^^-------------  ^^-----------^^   ^^---------------
 ^ ^ _k_ ^ ^  ^ ^ _K_ ^ ^   ^   _<C-k>_   ^   _s_: horizontally
 _h_ ^ ^ _l_  _H_ ^ ^ _L_   _<C-h>_ _<C-l>_   _v_: vertically
 ^ ^ _j_ ^ ^  ^ ^ _J_ ^ ^   ^   _<C-j>_   ^   _q_: close
 focus^^^^^^  ^swap ^^^^^   ^_=_: equalize^   _z_: maximize
 ^ ^ ^ ^ ^ ^  ^ ^ ^ ^ ^ ^   ^^ ^          ^   _o_: remain only
 _b_: choose buffer
]]

return require("hydra")({
  name = "Windows",
  short_name = "W󰖲",
  hint = window_hint,
  config = {
    desc = "hydra",
    color = "pink",
    invoke_on_body = true,
    hint = {
      border = "single",
      position = "bottom-left",
    },
  },
  mode = "n",
  body = "<C-w>w",
  heads = {
    {
      "h",
      function()
        require("smart-splits").move_cursor_left()
      end,
    },
    {
      "j",
      function()
        require("smart-splits").move_cursor_down()
      end,
    },
    {
      "k",
      function()
        require("smart-splits").move_cursor_up()
      end,
    },
    {
      "l",
      function()
        require("smart-splits").move_cursor_right()
      end,
    },

    { "H", cmd("WinShift left") },
    { "J", cmd("WinShift down") },
    { "K", cmd("WinShift up") },
    { "L", cmd("WinShift right") },

    {
      "<C-h>",
      function()
        require("smart-splits").resize_left(5)
      end,
    },
    {
      "<C-j>",
      function()
        require("smart-splits").resize_down(5)
      end,
    },
    {
      "<C-k>",
      function()
        require("smart-splits").resize_up(5)
      end,
    },
    {
      "<C-l>",
      function()
        require("smart-splits").resize_right(5)
      end,
    },
    { "=", cmd("FocusEqualise"), { desc = "equalize", exit = true } },

    { "s", pcmd("split", "E36") },
    { "<C-s>", pcmd("split", "E36"), { desc = false } },
    { "v", pcmd("vsplit", "E36") },
    { "<C-v>", pcmd("vsplit", "E36"), { desc = false } },

    { "z", cmd("FocusMaximise"), { exit = true, desc = "maximize" } },
    { "<C-z>", cmd("FocusMaximise"), { exit = true, desc = false } },

    { "o", "<C-w>o", { exit = true, desc = "remain only" } },
    { "<C-o>", "<C-w>o", { exit = true, desc = false } },

    {
      "b",
      function()
        require("cokeline.mappings").pick("focus")
      end,
      { exit = true, desc = "choose buffer" },
    },

    { "q", pcmd("close", "E444"), { desc = "close window" } },
    { "<C-c>", pcmd("close", "E444"), { desc = false } },
    { "<C-q>", pcmd("close", "E444"), { desc = false } },

    { "<Esc>", nil, { exit = true, desc = false } },
  },
})
