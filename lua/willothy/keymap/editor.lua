local keymap = require("willothy.util.keymap")
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

local objects = {
  w = "word",
  W = "WORD",
  ['"'] = 'string: ""',
  ["'"] = "string: ''",
  ["`"] = "string: ``",
  ["{"] = "block { }",
  ["}"] = "block { }",
  B = "block { }",
  ["<lt>"] = "block <>",
  [">"] = "block <>",
  ["["] = "block [",
  ["]"] = "block [",
  ["("] = "block (",
  [")"] = "block (",
  b = "block ( )",
  P = "paragraph",
  p = "paragraph",
  a = { name = "around" },
  i = { name = "inside" },
  s = "sentence",
  f = "function",
}

require("which-key").register({
  i = objects,
  a = objects,
}, { mode = "o" })

require("which-key").register({
  g = {
    name = "goto",
    ["?"] = bind("which-key", "show"):with_desc("which-key"),
    c = { name = "comment" },
    b = { name = "which_key_ignore" },
    g = "first line",
    x = "open hovered",
    r = bind("glance", "open", "references"):with_desc("lsp: references"),
    d = bind("glance", "open", "definitions"):with_desc("lsp:definitions"),
  },
}, { mode = modes.non_editing })

register({
  ["<C-F>"] = {
    bind("ssr", "open"),
    "search/replace",
  },
  v = {
    name = "visual",
  },
  K = bind("rust-tools.hover_actions", "hover_actions"):with_desc("lsp: hover"),
}, modes.non_editing)

require("which-key").register({
  [";"] = { "flash: next" },
  [","] = { "flash: prev" },
}, { mode = modes.non_editing + "o" })

require("which-key").register({
  j = "which_key_ignore",
  k = "which_key_ignore",
  h = "which_key_ignore",
  l = "which_key_ignore",
}, { mode = modes.all })

register({
  ["<F1>"] = bind("cokeline.mappings", "pick", "focus"):with_desc(
    "pick buffer"
  ),
  ["<C-Enter>"] = bind("willothy.terminals", "toggle"):with_desc(
    "terminal: toggle"
  ),
  ["<C-e>"] = bind("harpoon.ui", "toggle_quick_menu"):with_desc(
    "harpoon: toggle"
  ),
  ["<M-k>"] = bind("moveline", "up"):with_desc("move: up"),
  ["<M-j>"] = bind("moveline", "down"):with_desc("move: down"),
  ["<C-s>"] = bind(vim.cmd.write):with_desc("save"),
}, modes.non_editing + modes.insert)

register({
  ["<Tab>"] = { "V>", "Indent line" },
  ["<S-Tab>"] = { "V<", "Unindent line" },
  M = bind("multicursors", "start"),
}, modes.normal)

register({
  name = "marks",
  d = bind("marks", "delete"):with_desc("delete mark"),
  m = bind("reach", "marks"),
  h = bind("harpoon.mark", "toggle_file"):with_desc("harpoon: toggle mark"),
}, modes.non_editing, "<leader>m")

register({
  ["<F5>"] = {
    bind("configs.debugging.dap", "launch"),
    "dap: launch debugger",
  },
  ["<F8>"] = bind("dap", "toggle_breakpoint"),
  ["<F9>"] = bind("dap", "continue"),
  ["<F10>"] = bind("dap", "step_over"),
  ["<S-F10>"] = bind("dap", "step_out"),
  ["<F12>"] = bind("dap", "step_into"),
}, modes.normal)

register({
  ["<M-k>"] = { bind("moveline", "block_up"), "move: up" },
  ["<M-j>"] = { bind("moveline", "block_down"), "move: down" },
  ["<Tab>"] = { ">gv", "indent: increase" },
  ["<S-Tab>"] = { "<gv", "indent: decrease" },
  ["<C-c>"] = { '"+y', "copy selection" },
  ["M"] = { ":MCvisual<CR>", "multicursor mode" },
}, modes.visual)

local function fmt(name, is_after)
  return string.format("%s %s", name, is_after and "󱞣" or "󱞽")
end

register({
  p = {
    "<Plug>(YankyPutAfter)",
    fmt("put", true),
  },
  P = {
    "<Plug>(YankyPutBefore)",
    fmt("put"),
  },
  gp = {
    "<Plug>(YankyGPutAfter)",
    fmt("gput", true),
  },
  gP = {
    "<Plug>(YankyGPutBefore)",
    fmt("gput"),
  },
  ["]y"] = {
    "<Plug>(YankyCycleForward)",
    fmt("yanky: cycle", true),
  },
  ["[y"] = {
    "<Plug>(YankyCycleBackward)",
    fmt("yanky: cycle"),
  },
}, modes.non_editing)

register({
  s = {
    function()
      require("flash").jump()
    end,
    "flash: jump",
  },
}, { "n", "x", "v", "o" })

register({
  r = {
    function()
      local mode = vim.api.nvim_get_mode().mode
      if mode == "v" or mode == "V" or mode == "x" then
        require("flash").jump()
      else
        require("flash").remote()
      end
    end,
    "flash: remote",
  },
}, "o")

register({
  ["<C-s>"] = {
    function()
      require("flash").toggle()
    end,
    "flash: toggle flash search",
  },
}, modes.command)
