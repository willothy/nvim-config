local keymap = require("willothy.util.keymap")
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

register({
  ["<S-CR>"] = {
    bind("willothy.terminals", "toggle"),
    "Toggle terminal",
  },
  ["<S-Esc>"] = {
    bind("willothy.terminals", "toggle"),
    "Toggle terminal",
  },
  ["<C-Up>"] = bind("smart-splits", "move_cursor_up"),
  ["<C-Down>"] = bind("smart-splits", "move_cursor_down"),
  ["<C-Left>"] = bind("smart-splits", "move_cursor_left"),
  ["<C-Right>"] = bind("smart-splits", "move_cursor_right"),
  ["<M-Up>"] = bind("smart-splits", "resize_up"),
  ["<M-Down>"] = bind("smart-splits", "resize_down"),
  ["<M-Left>"] = bind("smart-splits", "resize_left"),
  ["<M-Right>"] = bind("smart-splits", "resize_right"),
  ["<C-k>"] = bind("smart-splits", "move_cursor_up"),
  ["<C-j>"] = bind("smart-splits", "move_cursor_down"),
  ["<C-h>"] = bind("smart-splits", "move_cursor_left"),
  ["<C-l>"] = bind("smart-splits", "move_cursor_right"),
  ["<C-w>"] = {
    name = "window",
    ["<Up>"] = bind("smart-splits", "move_cursor_up"),
    ["<Down>"] = bind("smart-splits", "move_cursor_down"),
    ["<Left>"] = bind("smart-splits", "move_cursor_left"),
    ["<Right>"] = bind("smart-splits", "move_cursor_right"),
    ["k"] = bind("smart-splits", "move_cursor_up"),
    ["j"] = bind("smart-splits", "move_cursor_down"),
    ["h"] = bind("smart-splits", "move_cursor_left"),
    ["l"] = bind("smart-splits", "move_cursor_right"),
    -- ["-"] = { "<nop>", "which_key_ignore" },
    -- ["<"] = { "<nop>", "which_key_ignore" },
    -- [">"] = { "<nop>", "which_key_ignore" },
    -- ["_"] = { "<nop>", "which_key_ignore" },
    -- o = {
    --   "<nop>",
    --   "which_key_ignore",
    -- },
    ["="] = {
      bind("focus", "focus_equalise"),
      "resize: equalize",
    },
    ["|"] = {
      bind("focus", "focus_maximise"),
      "resize: maximize",
    },
    ["\\"] = {
      bind("focus", "focus_max_or_equal"),
      "resize: max or equal",
    },
    ["+"] = {
      bind("focus", "resize"),
      "resize: golden ratio",
    },
    V = {
      function()
        local opt = vim.o.splitright
        vim.o.splitright = true
        vim.cmd("vsplit")
        vim.o.splitright = opt
      end,
      "split: right",
    },
    v = {
      function()
        local opt = vim.o.splitright
        vim.o.splitright = false
        vim.cmd("vsplit")
        vim.o.splitright = opt
      end,
      "split: left",
    },
    S = {
      function()
        local opt = vim.o.splitbelow
        vim.o.splitbelow = true
        vim.cmd("split")
        vim.o.splitbelow = opt
      end,
      "split: below",
    },
    s = {
      function()
        local opt = vim.o.splitbelow
        vim.o.splitbelow = false
        vim.cmd("split")
        vim.o.splitbelow = opt
      end,
      "split: above",
    },
    -- H = { "swap: left" },
    -- J = { "swap: down" },
    -- K = { "swap: up" },
    -- L = { "swap: right" },
    -- T = { "move to new tab" },
    f = {
      function()
        local win = require("window-picker").pick_or_create({
          filter_rules = {
            bo = {
              buftype = {},
            },
            include_current_win = false,
          },
        })
        if not win then return end
        vim.api.nvim_set_current_win(win)
      end,
      "pick: focus",
    },
    x = {
      function()
        local win = require("window-picker").pick_window({
          filter_rules = {
            autoselect_one = false,
            bo = {
              buftype = {
                "nofile",
                "nowrite",
                "prompt",
              },
            },
          },
        })
        if not win then return end
        local curwin = vim.api.nvim_get_current_win()
        if
          require("stickybuf").is_pinned(win)
          or require("stickybuf").is_pinned(curwin)
        then
          -- hack to fix window dimming
          vim.api.nvim_set_current_win(curwin)
          return
        end

        local buf = vim.api.nvim_win_get_buf(win)
        local curbuf = vim.api.nvim_get_current_buf()
        if buf == curbuf or win == curwin then return end

        vim.api.nvim_win_set_buf(win, curbuf)
        vim.api.nvim_win_set_buf(curwin, buf)
      end,
      "pick: swap",
    },
    q = {
      function()
        local win = require("window-picker").pick_window({
          filter_rules = {
            include_current_win = true,
            autoselect_one = false,
          },
        })
        if not win then return end
        local ok, res = pcall(vim.api.nvim_win_close, win, false)
        if not ok then
          if vim.startswith(res, "Vim:E444") then
            vim.ui.select({ "Close", "Cancel" }, {
              prompt = "Close window?",
            }, function(i)
              if i == "Close" then
                vim.api.nvim_exec2("qa!", { output = true })
              end
            end)
          else
            vim.notify("could not close window", vim.log.levels.WARN)
          end
        end
      end,
      "pick: close",
    },
  },
}, modes.non_pending)

register({
  ["<C-F>"] = {
    bind("ssr", "open"),
    "Structural Search/Replace",
  },
  ["<C-CR>"] = {
    bind("cokeline.mappings", "pick", "focus"),
    "Pick buffer",
  },
  g = {
    -- name = "goto",
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
