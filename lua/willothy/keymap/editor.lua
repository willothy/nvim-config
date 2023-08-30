local keymap = willothy.keymap
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
  s = "statement",
  f = "function",
  e = "expression",
}

require("which-key").register({
  i = objects,
  a = objects,
}, { mode = "o" })

require("which-key").register({
  g = {
    name = "go",
    ["?"] = bind("which-key", "show"):with_desc("which-key"),
    c = { name = "comment" },
    b = { name = "which_key_ignore" },
    g = "first line",
    x = "open hovered",
    r = bind("glance", "open", "references"):with_desc("lsp: references"),
    d = bind("glance", "open", "definitions"):with_desc("lsp: definitions"),
  },
  z = {
    z = {
      function()
        require("view_tween").scroll_actions.cursor_center(250)()
      end,
      "cursor: center",
    },
    b = {
      function()
        require("view_tween").scroll_actions.cursor_bottom(250)()
      end,
      "cursor: bottom",
    },
    t = {
      function()
        require("view_tween").scroll_actions.cursor_top(250)()
      end,
      "cursor: bottom",
    },
  },
  ["<C-u>"] = {
    function()
      require("view_tween").scroll_actions.half_page_up(250)()
    end,
    "half page down",
  },
  ["<C-d>"] = {
    function()
      require("view_tween").scroll_actions.half_page_down(250)()
    end,
    "half page up",
  },
}, { mode = modes.non_editing })

register({
  w = bind("spider", "motion", "w"):with_desc("which_key_ignore"),
  b = bind("spider", "motion", "b"):with_desc("which_key_ignore"),
  e = bind("spider", "motion", "e"):with_desc("which_key_ignore"),
  ge = bind("spider", "motion", "ge"):with_desc("which_key_ignore"),
}, { "n", "o", "x" })

local function scroll(dir)
  return function()
    local line_count = vim.api.nvim_buf_line_count(0)
    local count = math.min(math.max(vim.v.count, 1), line_count)

    local scrolloff = math.max(vim.o.scrolloff, 1)

    local height = vim.api.nvim_win_get_height(0)
    local view = vim.fn.winsaveview()
    if not view then
      return
    end
    local winline = view.lnum - view.topline
    local cursorline, cursorcol = view.lnum, view.curswant

    local target = function()
      if dir == "up" then
        return cursorline - count, winline - count
      else
        return cursorline + count, winline + count
      end
    end
    local target_line, target_view = target()
    if true then
      vim.print(target_view)
      -- return
    end

    local anim_cond = function()
      local off = scrolloff
      if dir == "up" then
        return target_view - off < 0
      else
        return target_view + off > height
      end
    end

    local LINE_TIME = 15
    local DISTANCE_ACCEL = 0.05

    if anim_cond() then
      local duration = LINE_TIME * count
      if count > 1 then
        duration = duration -- / (DISTANCE_ACCEL * count)
      end
      require("view_tween").scroll(0, target_view - winline, duration, false)
      vim.defer_fn(function()
        -- vim.api.nvim_win_set_cursor(0, { target_line, cursorcol })
        vim.fn.winrestview({
          curswant = cursorcol,
          lnum = target_line,
        })
      end, duration)
    else
      vim.api.nvim_win_set_cursor(0, { target_line, cursorcol })
      vim.fn.winrestview({
        curswant = cursorcol,
        lnum = target_line,
      })
    end
  end
end

register({
  ["<C-F>"] = {
    -- bind("ssr", "open"),
    bind("spectre", "toggle"),
    "search/replace",
  },
  v = {
    name = "visual",
  },
  K = bind("rust-tools.hover_actions", "hover_actions"):with_desc(
    "lsp: hover"
  ),
  -- j = {
  --   scroll("down"),
  --   "down",
  -- },
  -- k = {
  --   scroll("up"),
  --   "up",
  -- },
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
  ["<C-Enter>"] = bind(willothy.term, "toggle"):with_desc("terminal: toggle"),
  ["<C-e>"] = bind("harpoon.ui", "toggle_quick_menu"):with_desc(
    "harpoon: toggle"
  ),
  ["<M-k>"] = bind("moveline", "up"):with_desc("move: up"),
  ["<M-j>"] = bind("moveline", "down"):with_desc("move: down"),
  ["<C-s>"] = bind(vim.cmd.write):with_desc("save"),
}, modes.non_editing + modes.insert)

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
}, modes.normal)

register({
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
