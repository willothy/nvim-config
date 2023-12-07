local harpoon = require("harpoon")

local function ui_width_ratio()
  if vim.o.columns > 130 then
    return 0.35
  elseif vim.o.columns < 100 then
    return 0.55
  end

  return 0.45
end

harpoon:setup({
  settings = {
    save_on_toggle = true,
    border_chars = { " ", " ", " ", " ", " ", " ", " ", " " },
    -- key = function()
    --   return vim.uv.cwd() --[[@as string]]
    -- end,
    ui_fallback_width = 500,
    ui_width_ratio = ui_width_ratio(),
  },
})

vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("harpoon_ui_resize", { clear = true }),
  callback = function()
    harpoon:setup({
      settings = {
        ui_width_raio = ui_width_ratio(),
      },
    })
  end,
})

local listeners = harpoon.listeners
local event = require("harpoon.listeners").event_names

listeners:add_listener(function(evt)
  vim.notify(evt)
end)

-- listeners:add_listener(event.ADD, function(...)
--   vim.notify(vim.inspect({ ... }), vim.log.levels.INFO, {
--     title = "ADD",
--   })
-- end)
--
-- listeners:add_listener(event.SELECT, function(...)
--   vim.notify(vim.inspect({ ... }), vim.log.levels.INFO, {
--     title = "SELECT",
--   })
-- end)
--
-- listeners:add_listener(event.REMOVE, function(...)
--   vim.notify(vim.inspect({ ... }), vim.log.levels.INFO, {
--     title = "REMOVE",
--   })
-- end)

-- harpoon.setup({
--   menu = {
--     borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
--   },
--   global_settings = {
--     enter_on_sendcmd = true,
--   },
-- })
