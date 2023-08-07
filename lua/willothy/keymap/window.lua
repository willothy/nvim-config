local keymap = require("willothy.util.keymap")
local bind, register, modes = keymap.bind, keymap.register, keymap.modes

register({
  ["<S-CR>"] = {
    bind("willothy.terminals", "toggle"),
    "terminal",
  },
  ["<S-Esc>"] = {
    bind("trouble", "toggle", "document_diagnostics"),
    "diagnostics",
  },
  ["<C-Up>"] = { bind("smart-splits", "move_cursor_up") },
  ["<C-Down>"] = { bind("smart-splits", "move_cursor_down") },
  ["<C-Left>"] = { bind("smart-splits", "move_cursor_left") },
  ["<C-Right>"] = { bind("smart-splits", "move_cursor_right") },
  ["<M-Up>"] = { bind("smart-splits", "resize_up") },
  ["<M-Down>"] = { bind("smart-splits", "resize_down") },
  ["<M-Left>"] = { bind("smart-splits", "resize_left") },
  ["<M-Right>"] = { bind("smart-splits", "resize_right") },
  ["<C-k>"] = { bind("smart-splits", "move_cursor_up") },
  ["<C-j>"] = { bind("smart-splits", "move_cursor_down") },
  ["<C-h>"] = { bind("smart-splits", "move_cursor_left") },
  ["<C-l>"] = { bind("smart-splits", "move_cursor_right") },
  ["<C-w>"] = {
    name = "window",
    ["<Up>"] = { bind("smart-splits", "move_cursor_up") },
    ["<Down>"] = { bind("smart-splits", "move_cursor_down") },
    ["<Left>"] = { bind("smart-splits", "move_cursor_left") },
    ["<Right>"] = { bind("smart-splits", "move_cursor_right") },
    ["k"] = { bind("smart-splits", "move_cursor_up") },
    ["j"] = { bind("smart-splits", "move_cursor_down") },
    ["h"] = { bind("smart-splits", "move_cursor_left") },
    ["l"] = { bind("smart-splits", "move_cursor_right") },
    ["-"] = { "<nop>", noremap = true },
    ["<"] = { "<nop>", noremap = true },
    [">"] = { "<nop>", noremap = true },
    ["_"] = { "<nop>", noremap = true },
    ["o"] = { "<nop>" },
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
      bind("willothy.util.window", "split_right"),
      "split: right",
    },
    v = {
      bind("willothy.util.window", "split_left"),
      "split: left",
    },
    S = {
      bind("willothy.util.window", "split_below"),
      "split: below",
    },
    s = {
      bind("willothy.util.window", "split_above"),
      "split: above",
    },
    H = { "swap: left" },
    J = { "swap: down" },
    K = { "swap: up" },
    L = { "swap: right" },
    T = { "move to new tab" },
    f = {
      bind("willothy.util.window", "pick_focus"),
      "pick: focus",
    },
    x = {
      bind("willothy.util.window", "pick_swap"),
      "pick: swap",
    },
    q = {
      bind("willothy.util.window", "pick_close"),
      "pick: close",
    },
  },
}, modes.non_pending)
