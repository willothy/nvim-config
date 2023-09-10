local keymap = willothy.keymap
-- selene: allow(unused_variable)
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

register({
  ["<Esc>"] = { "<C-\\><C-n>", "Exit terminal" },
}, modes.terminal)

register({
  name = "terminal",
  t = {
    function()
      willothy.term.main:toggle()
    end,
    "terminal: toggle",
  },
  f = {
    function()
      willothy.term.float:toggle()
    end,
    "terminal: float toggle",
  },
  x = {
    function()
      willothy.term.xplr:toggle()
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
          willothy.term.send(v)
        end
      end)
    end,
    "terminal: send",
  },
  r = {
    name = "repl",
    p = {
      function()
        willothy.term.py:toggle()
      end,
      "python",
    },
    l = {
      function()
        willothy.term.lua:toggle()
      end,
      "lua",
    },
  },
}, modes.non_editing, "<leader>t")
