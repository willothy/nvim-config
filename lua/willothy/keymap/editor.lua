local keymap = require("willothy.util.keymap")
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

register({
  ["<C-F>"] = {
    bind("ssr", "open"),
    "search/replace",
  },
  g = {
    name = "goto",
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
  K = bind("rust-tools.hover_actions", "hover_actions"),
}, modes.non_editing)

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
  ["<M-s>"] = {
    function()
      require("flash").jump({ reverse = true })
    end,
    "flash: treesitter",
  },
  ["<M-r>"] = {
    function()
      -- show labeled treesitter nodes around the search matches
      require("flash").treesitter_search()
    end,
    "flash: treesitter Search",
  },
}, { "n", "x" })

register({
  r = {
    function()
      require("flash").remote()
    end,
    "flash: remote",
  },
}, modes.pending)

register({
  ["<C-s>"] = {
    function()
      require("flash").toggle()
    end,
    "flash: toggle flash search",
  },
}, modes.command)
