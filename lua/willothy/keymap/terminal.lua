local keymap = willothy.keymap
-- selene: allow(unused_variable)
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

register({
  ["<Esc>"] = { "<C-\\><C-n>", "Exit terminal" },
}, modes.terminal)

register({
  ["<C-Enter>"] = bind(willothy.term, "toggle"):with_desc("terminal: toggle"),
  ["<S-Enter>"] = {
    bind(willothy.term, "toggle"),
    "terminal",
  },
}, modes.non_editing + modes.terminal)

register({
  name = "terminal",
  t = {
    function()
      willothy.term.main:toggle()
    end,
    "main",
  },
  v = {
    function()
      willothy.term.vertical:toggle()
    end,
    "vertical",
  },
  f = {
    function()
      willothy.term.float:toggle()
    end,
    "float",
  },
  x = {
    function()
      willothy.term.xplr:toggle()
    end,
    "xplr",
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
    "send",
  },
  o = {
    "<cmd>OverseerFloat<cr>",
    "overseer: show",
  },
  r = {
    function()
      require("overseer").run_template()
    end,
    "overseer: run",
  },
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
}, modes.non_editing, "<leader>t")
