local keymap = require("willothy.util.keymap")
-- selene: allow(unused_variable)
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

register({
  ["<Esc>"] = { "<C-\\><C-n>", "Exit terminal" },
}, modes.terminal)

register({
  name = "terminal",
  t = {
    function()
      require("willothy.terminals").toggle()
    end,
    "terminal: toggle",
  },
  f = {
    function()
      require("willothy.terminals").toggle_float()
    end,
    "terminal: float toggle",
  },
  s = {
    function()
      vim.ui.input({
        prompt = "$ ",
        completion = "shellcmd",
      }, function(v)
        if v and type(v) == "string" then
          require("willothy.terminals").with():send(v)
        end
      end)
    end,
    "terminal: send",
  },
  r = {
    name = "repl",
    p = {
      function()
        require("willothy.terminals").py:toggle()
      end,
      "python",
    },
    l = {
      function()
        require("willothy.terminals").lua:toggle()
      end,
      "lua",
    },
  },
}, modes.non_editing, "<leader>t")
