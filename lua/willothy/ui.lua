local KeyCode = {
  Move = vim.keycode("<LeftDrag>"),
  Resize = vim.keycode("<S-LeftDrag>"),
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

local Modenr = {}

function Modenr.setup()
  local api = vim.api
  local function mode_name()
    local mode = api.nvim_get_mode().mode
    local mode_names = {
      ["n"] = "Normal",
      ["i"] = "Insert",
      ["v"] = "Visual",
      ["V"] = "Visual",
      [""] = "Visual",
      ["s"] = "Select",
      ["S"] = "Select",
      ["R"] = "Replace",
      ["c"] = "Command",
      ["t"] = "Terminal",
      ["nt"] = "TerminalNormal",
    }
    return mode_names[mode] or "Normal"
  end

  local function update_mode()
    local mode = mode_name()
    local hl = api.nvim_get_hl(0, { name = mode .. "Mode", link = false })
    api.nvim_set_hl(0, "CursorLineNr", hl)
  end
  update_mode()

  local group = api.nvim_create_augroup("Modenr", { clear = true })
  api.nvim_create_autocmd("ModeChanged", {
    group = group,
    callback = update_mode,
  })
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

return {
  setup = function()
    FloatDrag.setup()
    Modenr.setup()
  end,
  show_cursor = show_cursor,
  hide_cursor = hide_cursor,
}
