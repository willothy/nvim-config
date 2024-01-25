local keymap = willothy.keymap
local bind, modes = keymap.bind, keymap.modes

local function ai_textobjs(ai)
  return {
    w = "word",
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
    F = "function",
    p = "paragraph",
    u = {
      function()
        require("various-textobjs").url(ai)
      end,
      "url",
    },
    s = {
      function()
        require("various-textobjs").subword(ai)
      end,
      "subword",
    },
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
end

local wk = require("which-key")

wk.register({
  i = ai_textobjs("inner"),
  a = ai_textobjs("outer"),
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

local surrounds = {}

local function surround(l, r)
  local l_desc, r_desc = l, r
  if type(l) == "table" then
    l, l_desc = l[1], l[2]
  end
  if type(r) == "table" then
    r, r_desc = r[1], r[2]
  end

  table.insert(surrounds, {
    [l] = {
      function()
        require("nvim-surround")
        vim.api.nvim_feedkeys("S" .. l, vim.api.nvim_get_mode().mode, false)
      end,
      "surround: " .. l_desc .. r_desc,
    },
    [r] = {
      function()
        require("nvim-surround")
        vim.api.nvim_feedkeys("S" .. r, vim.api.nvim_get_mode().mode, false)
      end,
      "surround: " .. l_desc .. r_desc,
    },
  })
end

surround("(", ")")
surround("{", "}")
surround("[", "]")
-- surround({ "<lt>", "<" }, ">") -- conflicts with indents
-- surround('"', '"') -- conflicts with registers
-- surround("'", "'") -- conflicts with marks
-- surround("`", "`") -- conflicts with marks

-- surround mappings
wk.register(surrounds, { mode = { "v", "x" } })

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
  ["<C-e>"] = bind(function()
    local harpoon = require("harpoon")
    local list = harpoon:list("files")
    local width_ratio = 0.45
    if vim.o.columns > 130 then
      width_ratio = 0.35
    elseif vim.o.columns < 100 then
      width_ratio = 0.55
    end

    require("harpoon").ui:toggle_quick_menu(list, {
      ui_width_ratio = width_ratio,
      border = "solid",
      title_pos = "center",
      footer_pos = "center",
    })
  end):with_desc("harpoon: marks"),
  ["<C-c>"] = bind(function()
    local harpoon = require("harpoon")
    local list = harpoon:list("terminals")
    local width_ratio = 0.45
    if vim.o.columns > 130 then
      width_ratio = 0.35
    elseif vim.o.columns < 100 then
      width_ratio = 0.55
    end
    harpoon.ui:toggle_quick_menu(list, {
      ui_width_ratio = width_ratio,
      border = "solid",
      title_pos = "center",
      footer_pos = "center",
    })
  end):with_desc("harpoon: commands"),
  ["<C-t>"] = bind(function()
    local harpoon = require("harpoon")
    local list = harpoon:list("tmux")
    local width_ratio = 0.45
    if vim.o.columns > 130 then
      width_ratio = 0.35
    elseif vim.o.columns < 100 then
      width_ratio = 0.55
    end
    harpoon.ui:toggle_quick_menu(list, {
      ui_width_ratio = width_ratio,
      border = "solid",
      title_pos = "center",
      footer_pos = "center",
    })
  end):with_desc("harpoon: tmux sessions"),
  ["<C-a>"] = bind(function()
    local harpoon = require("harpoon")
    local list = harpoon:list("files")

    if list:length() == list:append():length() then
      list:remove()
    end
  end):with_desc("harpoon: toggle file"),
  ["<M-k>"] = bind("moveline", "up"):with_desc("move: up"),
  ["<M-j>"] = bind("moveline", "down"):with_desc("move: down"),
  ["<C-s>"] = bind(function()
    vim.cmd.write()
  end):with_desc("save"),
}, { mode = modes.non_editing })

vim.keymap.set("n", "<C-q>", function()
  require("NeoComposer.ui").toggle_macro_menu()
end, { silent = true, noremap = true, desc = "macro: open menu" })
vim.keymap.set({ "n", "x" }, "Q", function()
  require("NeoComposer.macro").toggle_play_macro()
end, { silent = true, noremap = true, desc = "macro: play" })
vim.keymap.set({ "n", "x" }, "q", function()
  require("NeoComposer.macro").toggle_record()
end, { silent = true, noremap = true, desc = "macro: record" })
vim.keymap.set("n", "cq", function()
  require("NeoComposer.macro").halt_macro()
end, { silent = true, noremap = true, desc = "macro: stop" })

-- vim.keymap.set("n", "<C-n>", function()
--   require("NeoComposer.ui").cycle_next()
-- end, { silent = true, noremap = true, desc = "macro: cycle next" })
-- vim.keymap.set("n", "<C-p>", function()
--   require("NeoComposer.ui").cycle_prev()
-- end, { silent = true, noremap = true, desc = "macro: cycle prev" })

wk.register({
  name = "marks",
  d = bind("marks", "delete"):with_desc("delete mark"),
  m = bind("reach", "marks"),
  h = bind(function()
    local list = require("harpoon"):list("files")

    if list:length() == list:append():length() then
      list:remove()
    end
  end):with_desc("harpoon: toggle mark"),
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
  ["<Tab>"] = bind(function()
    if vim.bo.modifiable then
      require("stay-in-place").shift_right_line()
    end
  end):with_desc("indent: increase"),
  ["<S-Tab>"] = bind(function()
    if vim.bo.modifiable then
      require("stay-in-place").shift_left_line()
    end
  end):with_desc("indent: decrease"),
  M = bind("multicursors", "start"),
  u = "edit: undo",
  ["<C-r>"] = "edit: redo",
  ["<"] = "indent: decrease",
  [">"] = "indent: increase",
  ["="] = "indent: auto",
}, { mode = modes.normal })

wk.register({
  ["<M-k>"] = bind("moveline", "block_up"):with_desc("move: up"),
  ["<M-j>"] = bind("moveline", "block_down"):with_desc("move: down"),
  ["<Tab>"] = bind(function()
    if vim.bo.modifiable then
      require("stay-in-place").shift_right_visual()
    end
  end):with_desc("indent: increase"),
  ["<S-Tab>"] = bind(function()
    if vim.bo.modifiable then
      require("stay-in-place").shift_left_visual()
    end
  end):with_desc("indent: decrease"),
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
    "<Plug>(YankyNextEntry)",
    fmt("yanky: cycle", true),
  },
  ["[y"] = {
    "<Plug>(YankyPreviousEntry)",
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
