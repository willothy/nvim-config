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

local NS = vim.api.nvim_create_namespace("willothy_scrollbar_thumb")

local hls_ready = false

-- Colours for the eighth-block thumb, derived from PmenuThumb: the block glyphs
-- need the thumb colour as a *foreground*, plus an inverted variant (Normal-bg
-- glyph over a thumb-coloured background) so the bottom edge can render as a
-- top-aligned partial. A transparent window bg lets the empty part of the top
-- edge show the buffer behind it.
--
-- Derived lazily (first show / after ColorScheme) rather than at module load,
-- so it reads the actual colorscheme instead of whatever happens to be loaded
-- when the scrollbar module first loads (which left these groups empty).
local function setup_highlights()
  local thumb = vim.api.nvim_get_hl(0, { name = "PmenuThumb", link = false })
  local thumb_color = thumb.bg or thumb.fg
  if not thumb_color then
    return
  end
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  vim.api.nvim_set_hl(0, "WillothyScrollbarThumb", { fg = thumb_color })
  vim.api.nvim_set_hl(
    0,
    "WillothyScrollbarThumbInv",
    { fg = normal.bg, bg = thumb_color }
  )
  vim.api.nvim_set_hl(0, "WillothyScrollbarBg", { bg = "NONE" })
  hls_ready = true
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    hls_ready = false
  end,
})

---@param opts willothy.ScrollbarConfig
---@return willothy.ScrollbarWin
function ScrollbarWindow.new(opts)
  return setmetatable(opts, ScrollbarWindow) --[[@as willothy.ScrollbarWin]]
end

function ScrollbarWindow:is_visible()
  return self.thumb_win ~= nil and vim.api.nvim_win_is_valid(self.thumb_win)
end

function ScrollbarWindow:show_thumb(geometry)
  if not hls_ready then
    setup_highlights()
  end

  -- per-thumb buffer holds the eighth-block chars; highlight each cell
  if self.thumb_buf == nil or not vim.api.nvim_buf_is_valid(self.thumb_buf) then
    self.thumb_buf = vim.api.nvim_create_buf(false, true)
  end
  vim.api.nvim_buf_set_lines(self.thumb_buf, 0, -1, false, geometry.lines)
  vim.api.nvim_buf_clear_namespace(self.thumb_buf, NS, 0, -1)
  for i, kind in ipairs(geometry.cell_hls) do
    vim.api.nvim_buf_set_extmark(self.thumb_buf, NS, i - 1, 0, {
      end_col = #geometry.lines[i],
      hl_group = kind == "thumb_inv" and "WillothyScrollbarThumbInv"
        or "WillothyScrollbarThumb",
    })
  end

  local pos = {
    relative = "win",
    win = geometry.win,
    width = 1,
    height = geometry.height,
    row = geometry.row,
    col = geometry.col,
    zindex = geometry.zindex,
    border = "none",
  }

  if self.thumb_win == nil or not vim.api.nvim_win_is_valid(self.thumb_win) then
    pos.style = "minimal"
    pos.focusable = false
    pos.noautocmd = true
    self.thumb_win = vim.api.nvim_open_win(self.thumb_buf, false, pos)
    vim.api.nvim_set_option_value(
      "winhighlight",
      "Normal:WillothyScrollbarBg,EndOfBuffer:WillothyScrollbarBg",
      { win = self.thumb_win }
    )
  else
    vim.api.nvim_win_set_config(self.thumb_win, pos)
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
    border = "none",
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
