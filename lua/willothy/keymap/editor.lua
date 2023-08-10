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
  t = "tag block",
}

require("which-key").register({
  i = objects,
  a = objects,
}, { mode = "o" })

register({
  ["<C-F>"] = {
    bind("ssr", "open"),
    "search/replace",
  },
  v = {
    name = "visual",
  },
  g = {
    name = "goto",
    ["?"] = {
      bind("which-key", "show"),
      "whick-key",
    },
    r = {
      bind("glance", "open", "references"),
      "references",
    },
    d = {
      bind("glance", "open", "definitions"),
      "definitions",
    },
    D = {
      vim.lsp.buf.declaration,
      "declaration",
    },
    T = {
      bind("glance", "open", "type_definitions"),
      "type definition",
    },
    i = {
      bind("glance", "open", "implementations"),
      "implementations",
    },
  },
  K = { bind("rust-tools.hover_actions", "hover_actions"), "lsp: hover" },
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
  ["<F1>"] = {
    bind("cokeline.mappings", "pick", "focus"),
    "Pick buffer",
  },
  ["<C-Enter>"] = { bind("willothy.terminals", "toggle"), "terminal: toggle" },
  ["<C-e>"] = { bind("harpoon.ui", "toggle_quick_menu"), "harpoon: toggle" },
  ["<M-k>"] = {
    bind("moveline", "up"),
    "move: up",
  },
  ["<M-j>"] = { bind("moveline", "down"), "move: down" },
  ["<C-s>"] = {
    vim.cmd.write,
    "Save",
  },
}, modes.non_editing + modes.insert)

register({
  name = "marks",
  m = {
    bind("reach", "marks"),
    "reach: marks",
  },
  h = {
    function()
      require("harpoon.mark").toggle_file()
    end,
    "harpoon: toggle mark",
  },
}, modes.non_editing, "<leader>m")

register({
  ["<F5>"] = {
    function()
      require("configs.debugging.dap").launch()
    end,
    "dap: launch debugger",
  },
  ["<F8>"] = {
    function()
      require("dap").toggle_breakpoint()
    end,
    "dap: toggle breakpoint",
  },
  ["<F9>"] = {
    function()
      require("dap").continue()
    end,
    "dap: continue",
  },
  ["<F10>"] = {
    function()
      require("dap").step_over()
    end,
    "dap: step over",
  },
  ["<S-F10>"] = {
    function()
      require("dap").step_into()
    end,
    "dap: step into",
  },
  ["<F12>"] = {
    function()
      require("dap.ui.widgets").hover()
    end,
    "dap: step out",
  },
}, modes.normal)

register({
  ["<M-k>"] = {
    function()
      require("moveline").block_up()
    end,
    "move: up",
  },
  ["<M-j>"] = {
    function()
      require("moveline").block_down()
    end,
    "move: down",
  },
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
    fmt("GPut", true),
  },
  gP = {
    "<Plug>(YankyGPutBefore)",
    fmt("GPut"),
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
