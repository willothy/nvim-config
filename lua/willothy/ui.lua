local KeyCode = {
  Move = vim.keycode("<LeftDrag>"),
  Resize = vim.keycode("<RightDrag>"),
  LeftRelease = vim.keycode("<LeftRelease>"),
  RightRelease = vim.keycode("<RightRelease>"),
  MiddleRelease = vim.keycode("<MiddleRelease>"),
}

local FloatDrag = {}

function FloatDrag:step()
  local ok, info = pcall(vim.fn.getmousepos)
  if not ok then return end

  self.screencol = info.screencol
  self.screenrow = info.screenrow
  if not self.w then
    self.w = info.winid
    self.c = info.wincol
    self.r = info.winrow
  end
end

function FloatDrag:drag()
  FloatDrag:step()
  local cfg = vim.api.nvim_win_get_config(self.w)
  if cfg.relative == "" then return end

  cfg.col[false] = self.screencol - self.c - 1
  cfg.row[false] = self.screenrow - self.r - 1
  vim.api.nvim_win_set_config(self.w, cfg)
end

function FloatDrag:resize()
  FloatDrag:step()

  local cfg = vim.api.nvim_win_get_config(self.w)
  if cfg.relative == "" then return end

  cfg.width = math.max(self.screencol - cfg.col[false] - cfg.col[true], 1)
  cfg.height = math.max(self.screenrow - cfg.row[false] - cfg.row[true], 1)
  vim.api.nvim_win_set_config(self.w, cfg)
end

function FloatDrag:reset()
  self.w = nil
  self.screencol = nil
  self.screenrow = nil
end

function FloatDrag.setup(opts)
  opts = opts or {}
  if opts.resize then KeyCode.Resize = vim.keycode(opts.resize) end
  if opts.move then KeyCode.Move = vim.keycode(opts.move) end
  vim.on_key(function(k)
    if k == KeyCode.Move then
      FloatDrag:drag()
    elseif k == KeyCode.Resize then
      FloatDrag:resize()
    elseif
      k == KeyCode.LeftRelease
      or k == KeyCode.RightRelease
      or k == KeyCode.MiddleRelease
    then
      FloatDrag:reset()
    end
  end)
end

local noice = require("noice.util.hacks")
local prev_cursor

local function hide_cursor()
  prev_cursor = noice._guicursor
  noice._guicursor = nil
end

local function show_cursor()
  noice._guicursor = prev_cursor
  prev_cursor = nil
end

vim.api.nvim_set_hl(0, "SepBorder", {
  fg = "#5de4c7",
  bg = "#26283f",
})

local buf
local win
local function update_border()
  local curwin = vim.api.nvim_get_current_win()
  local w = vim.api.nvim_win_get_width(curwin)
  local h = vim.api.nvim_win_get_height(curwin)
  local pos = vim.api.nvim_win_get_position(curwin)

  if not buf then buf = vim.api.nvim_create_buf(false, true) end
  if not win then
    win = vim.api.nvim_open_win(buf, false, {
      relative = "editor",
      width = w - 1,
      height = h - (pos[1] == 1 and 1 or 0),
      focusable = false,
      row = pos[1] - (pos[1] == 1 and 0 or 1),
      col = pos[2],
      style = "minimal",
      border = {
        "┏",
        "━",
        "┓",
        "┃",
        "┛",
        "━",
        "┗",
        "┃",
      },
    })
    vim.api.nvim_win_set_option(win, "winhighlight", "FloatBorder:SepBorder")
    vim.wo[win].winblend = 100
  else
    local conf = vim.api.nvim_win_get_config(win)
    conf.width = w - 1
    conf.height = h - (pos[1] == 1 and 1 or 0)
    conf.row = pos[1] - (pos[1] == 1 and 0 or 1)
    conf.col = pos[2]
    vim.api.nvim_win_set_config(win, conf)
  end
end

vim.api.nvim_create_autocmd({ "WinEnter", "WinResized" }, {
  callback = update_border,
})

vim.api.nvim_create_autocmd("WinClosed", {
  callback = function(ev)
    if ev.win == win then win = nil end
  end,
})

return {
  setup = FloatDrag.setup,
  show_cursor = show_cursor,
  hide_cursor = hide_cursor,
}
