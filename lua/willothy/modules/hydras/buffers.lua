local Hydra = require("willothy.modules.hydras").Hydra

return Hydra({
  name = "Buffers",
  body = "<leader>bh",
  shortname = "hydra",
  stl_name = "B󰈮",
  mode = "n",
  hint = [[
  focus     ^^move      ^^other
  --------  ^^--------  ^^-------------
  _h_: prev   _H_: prev   _p_: pin/unpin
  _l_: next   _L_: next   _c_: close

  _q_, _<Esc>_: exit
  ]],
  config = {
    hint = {
      type = "window",
      position = "bottom-left",
      border = "single",
      show_name = true,
    },
    color = "pink",
    invoke_on_body = true,
  },
  heads = {
    {
      "h",
      function()
        require("cokeline.mappings").by_step("focus", -1)
      end,
      { on_key = false },
    },
    {
      "l",
      function()
        require("cokeline.mappings").by_step("focus", 1)
      end,
      { desc = "choose", on_key = false },
    },
    {
      "H",
      function()
        require("cokeline.mappings").by_step("move", -1)
      end,
    },
    {
      "L",
      function()
        vim.cmd("BufferMoveNext")
        require("cokeline.mappings").by_step("move", 1)
      end,
      { desc = "move" },
    },
    {
      "p",
      function()
        require("harpoon.mark").toggle_file(vim.api.nvim_get_current_buf())
      end,
      { desc = "pin" },
    },
    {
      "c",
      function()
        require("cokeline.mappings").pick("close")
      end,
      { desc = false },
    },
    { "q", nil, { exit = true } },
    { "<Esc>", nil, { exit = true } },
  },
})
