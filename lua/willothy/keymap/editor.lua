local keymap = willothy.keymap
local bind, modes = keymap.bind, keymap.modes

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
  a = { name = "around" },
  i = { name = "inside" },
  s = "sentence",
  F = "function",
  p = "paragraph",
  d = {
    function()
      require("various-textobjs").diagnostic()
    end,
    "diagnostic",
  },
  f = {
    function()
      require("nvim-treesitter.textobjects.select").select_textobject(
        "@field",
        "field",
        "v"
      )
    end,
    "field",
  },
  e = "expression",
}

local wk = require("which-key")

wk.register({
  i = objects,
  a = objects,
}, { mode = { "o", "v" } })

wk.register({
  g = {
    name = "go",
    ["?"] = bind("which-key", "show"):with_desc("which-key"),
    c = { name = "comment" },
    b = { name = "which_key_ignore" },
    g = "first line",
    x = "open hovered",
    r = {
      vim.lsp.buf.references,
      "lsp: references",
    },
    d = {
      vim.lsp.buf.definition,
      "lsp: definitions",
    },
  },
  H = { "^", "start of line" },
  L = { "$", "end of line" },
}, { mode = modes.non_editing })

wk.register({
  ["<CR>"] = bind("wildfire", "init_selection"):with_desc("wildfire: init"),
}, { mode = modes.normal })

wk.register({
  ["<CR>"] = bind("wildfire", "node_incremental"):with_desc("wildfire: init"),
  ["<BS>"] = bind("wildfire", "node_decremental"):with_desc("wildfire: init"),
}, { mode = { "x", "v" } })

wk.register({
  w = bind("spider", "motion", "w"):with_desc("which_key_ignore"),
  b = bind("spider", "motion", "b"):with_desc("which_key_ignore"),
  e = bind("spider", "motion", "e"):with_desc("which_key_ignore"),
  ge = bind("spider", "motion", "ge"):with_desc("which_key_ignore"),
}, { mode = { "n", "o", "x", "v" } })

wk.register({
  ["<C-F>"] = {
    -- bind("ssr", "open"),
    bind("spectre", "toggle"),
    "search/replace",
  },
  v = {
    name = "visual",
  },
}, { mode = modes.non_editing })

wk.register({
  [";"] = { "flash: next" },
  [","] = { "flash: prev" },
}, { mode = modes.non_editing + "o" })

wk.register({
  j = "which_key_ignore",
  k = "which_key_ignore",
  h = "which_key_ignore",
  l = "which_key_ignore",
}, { mode = modes.all })

wk.register({
  ["<F1>"] = bind("cokeline.mappings", "pick", "focus"):with_desc(
    "pick buffer"
  ),
  ["<C-e>"] = bind("harpoon.ui", "toggle_quick_menu"):with_desc(
    "harpoon: marks"
  ),
  ["<C-c>"] = bind("harpoon.cmd-ui", "toggle_quick_menu"):with_desc(
    "harpoon: commands"
  ),
  ["<M-k>"] = bind("moveline", "up"):with_desc("move: up"),
  ["<M-j>"] = bind("moveline", "down"):with_desc("move: down"),
  ["<C-s>"] = bind(function()
    vim.cmd.write()
  end):with_desc("save"),
  -- macros
  ["<C-q>"] = bind("NeoComposer.ui", "toggle_macro_menu"):with_desc(
    "macro: open menu"
  ),
  Q = bind("NeoComposer.macro", "toggle_play_macro"):with_desc("macro: play"),
  q = bind("NeoComposer.macro", "toggle_record"):with_desc("macro: record"),
  cq = bind("NeoComposer.macro", "halt_macro"):with_desc("macro: stop"),
  ["<C-n>"] = bind("NeoComposer.ui", "cycle_next"):with_desc(
    "macro: cycle next"
  ),
  ["<C-p>"] = bind("NeoComposer.ui", "cycle_prev"):with_desc(
    "macro: cycle prev"
  ),
}, { mode = modes.non_editing })

wk.register({
  name = "marks",
  d = bind("marks", "delete"):with_desc("delete mark"),
  m = bind("reach", "marks"),
  h = bind("harpoon.mark", "toggle_file"):with_desc("harpoon: toggle mark"),
}, { mode = modes.non_editing, prefix = "<leader>m" })

wk.register({
  ["<F5>"] = {
    bind("configs.debugging.dap", "launch"),
    "dap: launch debugger",
  },
  ["<F8>"] = bind("dap", "toggle_breakpoint"),
  ["<F9>"] = bind("dap", "continue"),
  ["<F10>"] = bind("dap", "step_over"),
  ["<S-F10>"] = bind("dap", "step_out"),
  ["<F12>"] = bind("dap", "step_into"),
}, { mode = modes.normal })

wk.register({
  ["<Tab>"] = bind("stay-in-place", "shift_right_line"):with_desc(
    "indent: increase"
  ),
  ["<S-Tab>"] = bind("stay-in-place", "shift_left_line"):with_desc(
    "indent: decrease"
  ),
  M = bind("multicursors", "start"),
  u = "edit: undo",
  ["<C-r>"] = "edit: redo",
  ["<"] = "indent: decrease",
  [">"] = "indent: increase",
  ["="] = "indent: auto",
}, { mode = modes.normal })

wk.register({
  ["<M-k>"] = { bind("moveline", "block_up"), "move: up" },
  ["<M-j>"] = { bind("moveline", "block_down"), "move: down" },
  ["<Tab>"] = bind("stay-in-place", "shift_right_visual"):with_desc(
    "indent: increase"
  ),
  ["<S-Tab>"] = bind("stay-in-place", "shift_left_visual"):with_desc(
    "indent: decrease"
  ),
  ["<C-c>"] = { '"+y', "copy selection" },
  ["M"] = { ":MCvisual<CR>", "multicursor mode" },
  ["<"] = "indent: decrease",
  [">"] = "indent: increase",
  ["="] = "indent: auto",
}, { mode = modes.visual })

local function fmt(name, is_after)
  return string.format("%s %s", name, is_after and "󱞣" or "󱞽")
end

wk.register({
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
}, { mode = { "n", "x", "v", "o" } })

wk.register({
  s = {
    function()
      require("flash").jump()
    end,
    "flash: jump",
  },
}, { mode = { "n", "x", "v", "o" } })

wk.register({
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
}, { mode = "o" })

wk.register({
  ["<C-s>"] = {
    function()
      require("flash").toggle()
    end,
    "flash: toggle flash search",
  },
  ["<C-f>"] = {
    function() end,
    "which_key_ignore",
  },
}, { mode = modes.command })
