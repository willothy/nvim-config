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
    save_on_change = true,
    border_chars = { " ", " ", " ", " ", " ", " ", " ", " " },
    key = function()
      return vim.uv.cwd() --[[@as string]]
    end,
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

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "harpoon" },
  group = vim.api.nvim_create_augroup("harpoon_ui_save", { clear = true }),
  callback = function(ev)
    vim.api.nvim_create_autocmd("TextChanged", {
      buffer = ev.buf,
      callback = function()
        harpoon.ui:save()
      end,
    })
  end,
})

local Path = require("plenary.path")
local fidget = require("fidget")

local function notify(event, cx)
  local path = Path:new(cx.item.value) --[[@as Path]]

  local display = path:make_relative(vim.uv.cwd())
    or path:make_relative(vim.env.HOME)
    or path:normalize()

  fidget.progress.handle.create({
    lsp_client = {
      name = "harpoon",
    },
    title = event,
    message = display,
    level = vim.log.levels.ERROR,
  })
end

harpoon.listeners:add_listener(function(ev, cx)
  if ev == "ADD" then
    notify("added", cx)
  elseif ev == "REMOVE" then
    notify("removed", cx)
  elseif ev == "MOVE" then
    notify("moved", cx)
  end
end, "")
