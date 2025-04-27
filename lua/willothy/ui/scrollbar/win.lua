--- Manages creating/updating scrollbar gutter and thumb windows

--- @class willothy.ScrollbarWin
--- @field enable_gutter boolean
--- @field thumb_win? number
--- @field gutter_win? number
--- @field buf? number
---
--- @field new fun(opts: willothy.ScrollbarConfig): willothy.ScrollbarWin
--- @field is_visible fun(self: willothy.ScrollbarWin): boolean
--- @field show_thumb fun(self: willothy.ScrollbarWin, geometry: willothy.ScrollbarGeometry)
--- @field show_gutter fun(self: willothy.ScrollbarWin, geometry: willothy.ScrollbarGeometry)
--- @field hide_thumb fun(self: willothy.ScrollbarWin)
--- @field hide_gutter fun(self: willothy.ScrollbarWin)
--- @field hide fun(self: willothy.ScrollbarWin)
--- @field _make_win fun(self: willothy.ScrollbarWin, geometry: willothy.ScrollbarGeometry, hl_group: string): number
--- @field redraw_if_needed fun(self: willothy.ScrollbarWin)
local ScrollbarWindow = {}

ScrollbarWindow.__index = ScrollbarWindow

---@param opts willothy.ScrollbarConfig
---@return willothy.ScrollbarWin
function ScrollbarWindow.new(opts)
  return setmetatable(opts, ScrollbarWindow) --[[@as willothy.ScrollbarWin]]
end

function ScrollbarWindow:is_visible()
  return self.thumb_win ~= nil and vim.api.nvim_win_is_valid(self.thumb_win)
end

function ScrollbarWindow:show_thumb(geometry)
  -- create window if it doesn't exist
  if
    self.thumb_win == nil or not vim.api.nvim_win_is_valid(self.thumb_win)
  then
    self.thumb_win = self:_make_win(geometry, "PmenuThumb")
  else
    -- update with the geometry
    local thumb_existing_config = vim.api.nvim_win_get_config(self.thumb_win)
    local thumb_config =
      vim.tbl_deep_extend("force", thumb_existing_config, geometry)
    vim.api.nvim_win_set_config(self.thumb_win, thumb_config)
  end

  self:redraw_if_needed()
end

function ScrollbarWindow:show_gutter(geometry)
  if not self.enable_gutter then
    return
  end

  -- create window if it doesn't exist
  if
    self.gutter_win == nil or not vim.api.nvim_win_is_valid(self.gutter_win)
  then
    self.gutter_win = self:_make_win(geometry, "PmenuSbar")
  else
    -- update with the geometry
    local gutter_existing_config = vim.api.nvim_win_get_config(self.gutter_win)
    local gutter_config =
      vim.tbl_deep_extend("force", gutter_existing_config, geometry)
    vim.api.nvim_win_set_config(self.gutter_win, gutter_config)
  end

  self:redraw_if_needed()
end

function ScrollbarWindow:hide_thumb()
  if self.thumb_win and vim.api.nvim_win_is_valid(self.thumb_win) then
    vim.api.nvim_win_close(self.thumb_win, true)
    self.thumb_win = nil
    self:redraw_if_needed()
  end
end

function ScrollbarWindow:hide_gutter()
  if self.gutter_win and vim.api.nvim_win_is_valid(self.gutter_win) then
    vim.api.nvim_win_close(self.gutter_win, true)
    self.gutter_win = nil
    self:redraw_if_needed()
  end
end

function ScrollbarWindow:hide()
  self:hide_thumb()
  self:hide_gutter()
end

function ScrollbarWindow:_make_win(geometry, hl_group)
  if self.buf == nil or not vim.api.nvim_buf_is_valid(self.buf) then
    self.buf = vim.api.nvim_create_buf(false, true)
  end

  local win_config = vim.tbl_deep_extend("force", geometry, {
    style = "minimal",
    focusable = false,
    noautocmd = true,
  })
  local win = vim.api.nvim_open_win(
    self.buf,
    false,
    win_config --[[@as vim.api.keyset.win_config]]
  )
  vim.api.nvim_set_option_value(
    "winhighlight",
    "Normal:" .. hl_group .. ",EndOfBuffer:" .. hl_group,
    { win = win }
  )
  return win
end

function ScrollbarWindow:redraw_if_needed()
  vim.schedule(function()
    if
      self.gutter_win ~= nil and vim.api.nvim_win_is_valid(self.gutter_win)
    then
      vim.api.nvim__redraw({ win = self.gutter_win, valid = true })
    end
    if self.thumb_win ~= nil and vim.api.nvim_win_is_valid(self.thumb_win) then
      vim.api.nvim__redraw({ win = self.thumb_win, valid = true })
    end
  end)
end

return ScrollbarWindow
