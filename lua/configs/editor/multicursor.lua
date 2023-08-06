local N = require("multicursors.normal_mode")
local I = require("multicursors.insert_mode")

local mc = require("multicursors")
mc.setup({
  normal_keys = {
    [","] = {
      method = N.clear_others,
      opts = { desc = "clear others" },
    },
  },
  insert_keys = {
    ["<CR>"] = {
      method = I.Cr_method,
      opts = { desc = "new line" },
    },
  },
  hint_config = {
    border = true,
  },
  generate_hints = {
    normal = true,
    insert = true,
    extend = true,
  },
})

local utils = require("multicursors.utils")

local function then_exec(f, autocmd)
  return function(...)
    f(...)
    vim.api.nvim_exec_autocmds("User", {
      pattern = autocmd,
    })
  end
end

-- monkeypatch so statusline updates properly
local exit = utils.exit
utils.exit = then_exec(exit, "HydraLeave")

local start = mc.start
mc.start = then_exec(start, "HydraEnter")

local new_under_cursor = mc.new_under_cursor
mc.new_under_cursor = then_exec(new_under_cursor, "HydraEnter")

local search_visual = mc.search_visual
mc.search_visual = then_exec(search_visual, "HydraEnter")

local new_pattern = mc.new_pattern
mc.new_pattern = then_exec(new_pattern, "HydraEnter")

local new_pattern_visual = mc.new_pattern_visual
mc.new_pattern_visual = then_exec(new_pattern_visual, "HydraEnter")
