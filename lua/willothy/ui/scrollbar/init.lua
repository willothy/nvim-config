--- @class willothy.ScrollbarConfig
--- @field enable_gutter boolean

--- @class willothy.Scrollbar
--- @field win willothy.ScrollbarWin
---
--- @field new fun(opts: willothy.ScrollbarConfig): willothy.Scrollbar
--- @field is_visible fun(self: willothy.Scrollbar): boolean
--- @field update fun(self: willothy.Scrollbar, target_win: number | nil)

--- @type willothy.Scrollbar
--- @diagnostic disable-next-line: missing-fields
local scrollbar = {}

function scrollbar.new(opts)
  local self = setmetatable({}, { __index = scrollbar })
  self.win = require("willothy.ui.scrollbar.win").new(opts)
  return self
end

function scrollbar:is_visible()
  return self.win:is_visible()
end

function scrollbar:update(target_win)
  if target_win == nil or not vim.api.nvim_win_is_valid(target_win) then
    return self.win:hide()
  end

  local geometry =
    require("willothy.ui.scrollbar.geometry").get_geometry(target_win)
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
  local old = vim
    .iter(pairs(ScrollBarManager.bars))
    :fold({}, function(acc, winnr)
      acc[winnr] = true
      return acc
    end)
  vim
    .iter(vim.api.nvim_tabpage_list_wins(0))
    :filter(function(win)
      local winbuf = vim.api.nvim_win_get_buf(win)
      return vim.bo[winbuf].buftype == ""
        and vim.bo[winbuf].filetype ~= "noice"
        and vim.api.nvim_win_get_config(win).zindex == nil
    end)
    :each(function(win)
      if not ScrollBarManager.bars[win] then
        local bar = scrollbar.new({
          enable_gutter = false,
        })
        ScrollBarManager.bars[win] = bar
      end
      ScrollBarManager.bars[win]:update(win)
      old[win] = nil
    end)
  vim.iter(pairs(old)):each(function(w)
    if ScrollBarManager.bars[w] then
      ScrollBarManager.bars[w]:update()
      ScrollBarManager.bars[w] = nil
    end
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
  vim.api.nvim_create_autocmd({
    "WinNew",
    "WinClosed",
    "CursorMoved",
    "CursorMovedI",
    "WinScrolled",
    "WinResized",
    "VimResized",
  }, {
    callback = vim.schedule_wrap(function()
      ScrollBarManager.update()
    end),
  })

  vim.schedule(ScrollBarManager.update)
end

return ScrollBarManager
