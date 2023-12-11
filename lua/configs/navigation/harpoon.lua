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
  ["terminals"] = {
    -- encode = function() end,
    prepopulate = function()
      return {
        {
          value = "echo 'hello'",
        },
      }
    end,
    display = function(item)
      return item.value
    end,
    add = function(item)
      return { value = item }
    end,
    select = function(list_item, list, option)
      -- WOAH, IS THIS HTMX LEVEL XSS ATTACK??
    end,
  },
  -- Setting up custom behavior for a list named "cmd"
  ["cmd"] = {
    -- When you call list:append() this function is called and the return
    -- value will be put in the list at the end.
    --
    -- which means same behavior for prepend except where in the list the
    -- return value is added
    --
    -- @param possible_value string only passed in when you alter the ui manual
    add = function(possible_value)
      -- get the current line idx
      local idx = vim.fn.line(".")

      -- read the current line
      local cmd = vim.api.nvim_buf_get_lines(0, idx - 1, idx, false)[1]
      if cmd == nil then
        return nil
      end

      return {
        value = cmd,
        context = {},
      }
    end,

    --- This function gets invoked with the options being passed in from
    --- list:select(index, <...options...>)
    --- @param list_item {value: any, context: any}
    --- @param list { ... }
    --- @param option any
    select = function(list_item, list, option)
      -- WOAH, IS THIS HTMX LEVEL XSS ATTACK??
      vim.cmd(list_item.value)
    end,
  },
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
  elseif ev == "UI_CREATE" then
    -- vim.api.nvim_win_set_config(cx.win_id, {
    --   title_pos = "center",
    --   footer_pos = "center",
    --   footer = harpoon.ui.active_list and harpoon.ui.active_list.name,
    -- })
  end
end

---@diagnostic disable-next-line: missing-parameter
harpoon.listeners:add_listener(updater)
