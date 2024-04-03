local smart_splits = require("smart-splits")

local api = require("smart-splits.api")
for _, direction in ipairs({ "up", "down", "left", "right" }) do
  local fn = api["move_cursor_" .. direction]
  api["move_cursor_" .. direction] = function(...)
    local dir_key
    if direction == "up" then
      dir_key = "k"
    elseif direction == "down" then
      dir_key = "j"
    elseif direction == "left" then
      dir_key = "h"
    elseif direction == "right" then
      dir_key = "l"
    end

    if
      vim.fn.winnr() == vim.fn.winnr(dir_key)
      and require("smart-splits.mux").get().current_pane_at_edge(direction)
    then
      if direction == "left" then
        require("wezterm").switch_tab.relative(-1)
      else
        require("wezterm").switch_tab.relative(1)
      end
    else
      return fn(...)
    end
  end
end

smart_splits.setup({
  at_edge = "stop",
  resize_mode = {
    hooks = {
      on_leave = require("bufresize").register,
    },
  },
  ignore_events = {
    "WinResized",
    "BufWinEnter",
    "BufEnter",
    "WinEnter",
  },
})
