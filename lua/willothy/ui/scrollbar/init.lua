--- @class willothy.ScrollbarConfig
--- @field enable_gutter boolean

local Geometry = require("willothy.ui.scrollbar.geometry")
local ScrollbarWin = require("willothy.ui.scrollbar.win")

--- @class willothy.Scrollbar
--- @field win willothy.ScrollbarWin
---
--- @field new fun(opts: willothy.ScrollbarConfig): willothy.Scrollbar
--- @field is_visible fun(self: willothy.Scrollbar): boolean
--- @field update fun(self: willothy.Scrollbar, target_win: number | nil)
local Scrollbar = {}

function Scrollbar.new(opts)
  local self = setmetatable({}, { __index = Scrollbar })
  self.win = ScrollbarWin.new(opts)
  return self
end

function Scrollbar:is_visible()
  return self.win:is_visible()
end

function Scrollbar:update(target_win)
  if target_win == nil or not vim.api.nvim_win_is_valid(target_win) then
    return self.win:hide()
  end

  local geometry = Geometry.get_geometry(target_win)
  if geometry.should_hide then
    return self.win:hide()
  end

  self.win:show_thumb(geometry.thumb)
  self.win:show_gutter(geometry.gutter)
end

local ScrollBarManager = {
  bars = {},
}

function ScrollBarManager.update()
  local tabpage = vim.api.nvim_get_current_tabpage()

  vim
    .iter(vim.api.nvim_tabpage_list_wins(tabpage))
    :filter(function(win)
      local buf = vim.api.nvim_win_get_buf(win)

      -- short-circuit here to avoid creating win config objects unnecessarily
      return vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "noice"
    end)
    :filter(function(win)
      return vim.api.nvim_win_get_config(win).relative == ""
    end)
    :each(function(win)
      if not ScrollBarManager.bars[win] then
        local bar = Scrollbar.new({
          enable_gutter = false,
        })
        ScrollBarManager.bars[win] = bar
      end
      ScrollBarManager.bars[win]:update(win)
    end)

  vim
    .iter(pairs(ScrollBarManager.bars))
    :filter(function(w)
      return vim.api.nvim_win_is_valid(w) == false
        or vim.api.nvim_win_get_tabpage(w) ~= tabpage
    end)
    :each(function(w, bar)
      ScrollBarManager.bars[w] = nil
      bar:update()
    end)
end

function ScrollBarManager.clear()
  vim.iter(ScrollBarManager.bars):each(function(w)
    ScrollBarManager.bars[w]:update()
    ScrollBarManager.bars[w] = nil
  end)
end

function ScrollBarManager.setup(opts)
  ScrollBarManager.options = opts or {}

  -- Coalesce updates: at most once per `interval` ms, but always a trailing
  -- update so the thumb settles at the final position after a burst of
  -- cursor/scroll events (rather than running a full update per event).
  local interval = 16
  local timer = assert((vim.uv or vim.loop).new_timer())
  local scheduled = false
  local function request_update()
    if scheduled then
      return
    end
    scheduled = true
    timer:start(
      interval,
      0,
      vim.schedule_wrap(function()
        scheduled = false
        ScrollBarManager.update()
      end)
    )
  end

  vim.api.nvim_create_autocmd({
    "WinNew",
    "WinClosed",
    "CursorMoved",
    "CursorMovedI",
    "WinScrolled",
    "WinResized",
    "VimResized",
  }, {
    callback = request_update,
  })

  vim.schedule(ScrollBarManager.update)
end

return ScrollBarManager
