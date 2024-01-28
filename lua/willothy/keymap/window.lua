local keymap = willothy.map
local bind, modes = keymap.bind, keymap.modes

local function resize(direction)
  return function()
    local win = vim.api.nvim_get_current_win()
    local config = vim.api.nvim_win_get_config(win)
    if config.zindex ~= nil then
      if direction == "up" then
        config.height = config.height - vim.v.count1
      elseif direction == "down" then
        config.height = config.height + vim.v.count1
      elseif direction == "left" then
        config.width = config.width - vim.v.count1
      elseif direction == "right" then
        config.width = config.width + vim.v.count1
      end
      vim.api.nvim_win_set_config(win, config)
      return
    end
    require("smart-splits")["resize_" .. direction]()
  end,
    "resize: " .. direction
end

local wk = require("which-key")

wk.register({
  ["<C-Up>"] = bind("smart-splits", "move_cursor_up"),
  ["<C-Down>"] = { bind("smart-splits", "move_cursor_down") },
  ["<C-Left>"] = { bind("smart-splits", "move_cursor_left") },
  ["<C-Right>"] = { bind("smart-splits", "move_cursor_right") },
  -- ["<M-Up>"] = { bind("smart-splits", "resize_up") },
  -- ["<M-Down>"] = { bind("smart-splits", "resize_down") },
  -- ["<M-Left>"] = { bind("smart-splits", "resize_left") },
  -- ["<M-Right>"] = { bind("smart-splits", "resize_right") },
  ["<M-Up>"] = { resize("up") },
  ["<M-Down>"] = { resize("down") },
  ["<M-Left>"] = { resize("left") },
  ["<M-Right>"] = { resize("right") },
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
      bind("focus", "focus_autoresize"),
      "resize: golden ratio",
    },
    V = {
      willothy.win.split_right,
      "split: right",
    },
    v = {
      willothy.win.split_left,
      "split: left",
    },
    S = {
      willothy.win.split_below,
      "split: below",
    },
    s = {
      willothy.win.split_above,
      "split: above",
    },
    H = "swap: left",
    J = "swap: down",
    K = "swap: up",
    L = "swap: right",
    T = "move to new tab",
    f = {
      willothy.win.pick_focus,
      "pick: focus",
    },
    c = {
      willothy.win.pick_create,
      "pick: create",
    },
    x = {
      willothy.win.pick_swap,
      "pick: swap",
    },
    q = {
      willothy.win.pick_close,
      "pick: close",
    },
  },
}, { mode = modes.non_pending })
