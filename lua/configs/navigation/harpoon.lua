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
    save_on_toggle = false,
    sync_on_ui_close = true,
    -- save_on_change = true,
    border_chars = { " ", " ", " ", " ", " ", " ", " ", " " },
    ui = {
      border = { " ", " ", " ", " ", " ", " ", " ", " " },
      falback_width = 100,
      width_ratio = ui_width_ratio(),
    },
    key = function()
      return vim.uv.cwd() --[[@as string]]
    end,
    debug = true,
  },
  -- ["terminals"] = {
  --
  -- }
})

vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("harpoon_ui_resize", { clear = true }),
  callback = function()
    harpoon:setup({
      settings = {
        ui = {
          width_ratio = ui_width_ratio(),
        },
      },
    })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "harpoon" },
  group = vim.api.nvim_create_augroup("harpoon_ui_save", { clear = true }),
  callback = function(ev)
    vim.keymap.set("n", "<C-v>", function()
      harpoon.ui:select_menu_item({ vsplit = true })
    end, { buffer = ev.buf })
    vim.keymap.set("n", "<C-s>", function()
      harpoon.ui:select_menu_item({ split = true })
    end, { buffer = ev.buf })

    vim.api.nvim_create_autocmd("TextChanged", {
      buffer = ev.buf,
      callback = willothy.fn.debounce_leading(
        vim.schedule_wrap(function()
          harpoon.ui:save()
        end),
        1000
      ),
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

local updater = function(ev, cx)
  if ev == "ADD" then
    notify("added", cx)
  elseif ev == "REMOVE" then
    notify("removed", cx)
  end
end

harpoon.listeners:add_listener(updater)

vim.api.nvim_create_user_command("HDetach", function()
  harpoon.listeners:remove_listener(updater)
end, {})
