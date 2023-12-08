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

local fidget = require("fidget")

local function notify(event, cx)
  fidget.progress.handle.create({
    lsp_client = {
      name = "harpoon",
    },
    title = event,
    message = vim.fs.basename(cx.list:display()[cx.idx]),
    level = vim.log.levels.ERROR,
  })
end

harpoon.listeners:add_listener(function(ev, cx)
  if ev == "ADD" then
    notify("added", cx)
  elseif ev == "REMOVE" then
    notify("removed", cx)
  end
  vim.schedule(function()
    require("harpoon"):sync()
  end)
end, "")
