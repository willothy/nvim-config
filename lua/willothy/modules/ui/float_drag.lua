local KeyCode = {
  Move = vim.keycode("<LeftDrag>"),
  Resize = vim.keycode("<M-LeftDrag>"),
  LeftRelease = vim.keycode("<LeftRelease>"),
  RightRelease = vim.keycode("<RightRelease>"),
  MiddleRelease = vim.keycode("<MiddleRelease>"),
}

local FloatDrag = {}

function FloatDrag:step()
  local info = vim.fn.getmousepos()
  if not info then
    return
  end

  self.screencol = info.screencol
  self.screenrow = info.screenrow
  if not self.win then
    self.win = info.winid
    self.wincol = info.wincol
    self.winrow = info.winrow
  end
end

function FloatDrag:drag()
  FloatDrag:step()
  local cfg = vim.api.nvim_win_get_config(self.win)
  if cfg.zindex == nil then
    return
  end

  if self.winrow > 2 then
    self:reset()
    return
  end
  self.winrow = 1

  cfg.col = self.screencol - self.wincol - 1
  cfg.row = self.screenrow - self.winrow - (cfg.title == nil and 0 or 1)
  vim.api.nvim_win_set_config(self.win, cfg)
end

function FloatDrag:resize()
  local first = false
  if not self.win then
    first = true
  end
  FloatDrag:step()

  local cfg = vim.api.nvim_win_get_config(self.win)
  if cfg.zindex == nil then
    return
  end

  if first then
    local mouse = vim.fn.getmousepos()
    if mouse.winrow ~= cfg.height or mouse.wincol ~= cfg.width then
      self:reset()
      return
    end
  end

  cfg.width = math.max(self.screencol - cfg.col[false] - 2, 1)
  cfg.height = math.max(self.screenrow - cfg.row[false] - 2, 1)
  vim.api.nvim_win_set_config(self.win, cfg)
end

function FloatDrag:reset()
  self.win = nil
  self.screencol = nil
  self.screenrow = nil
  self.winrow = nil
  self.wincol = nil
end

function FloatDrag.setup(opts)
  opts = opts or {}
  if opts.resize then
    KeyCode.Resize = vim.keycode(opts.resize)
  end
  if opts.move then
    KeyCode.Move = vim.keycode(opts.move)
  end
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

return FloatDrag
