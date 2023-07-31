local notify = require("notify")

local stages_util = require("notify.stages.util")
local Dir = stages_util.DIRECTION

local function anim(direction)
  return {
    function(state)
      local next_row = stages_util.available_slot(
        state.open_windows,
        state.message.height,
        direction
      )
      if not next_row then return nil end
      return {
        relative = "editor",
        anchor = "NE",
        width = 1,
        height = state.message.height,
        col = vim.opt.columns:get(),
        row = next_row,
        border = "rounded",
        style = "minimal",
      }
    end,
    function(state, win)
      return {
        width = { state.message.width },
        col = { vim.opt.columns:get() },
        row = {
          stages_util.slot_after_previous(win, state.open_windows, direction),
          frequency = 3,
          complete = function()
            return true
          end,
        },
      }
    end,
    function(state, win)
      return {
        col = { vim.opt.columns:get() },
        time = true,
        row = {
          stages_util.slot_after_previous(win, state.open_windows, direction),
          frequency = 3,
          complete = function()
            return true
          end,
        },
      }
    end,
    function(state, win)
      return {
        width = {
          1,
          frequency = 2.5,
          damping = 0.9,
          complete = function(cur_width)
            return cur_width < 3
          end,
        },
        col = { vim.opt.columns:get() },
        row = {
          stages_util.slot_after_previous(win, state.open_windows, direction),
          frequency = 3,
          complete = function()
            return true
          end,
        },
      }
    end,
  }
end

notify.setup({
  fps = 60,
  render = "compact",
  timeout = 3000,
  stages = anim(Dir.TOP_DOWN),
  -- top_down = false,
  background_color = "none",
})
