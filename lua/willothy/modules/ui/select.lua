---@diagnostic disable: inject-field
--- UI select module using Dropbar.nvim

-- utils for code actions

local M = {}

function M.ui_select(items, opts, on_choice)
  if not items then
    return
  end

  local dropbar_menu_t = require("dropbar.menu").dropbar_menu_t
  local dropbar_menu_entry_t = require("dropbar.menu").dropbar_menu_entry_t
  local dropbar_symbol_t = require("dropbar.bar").dropbar_symbol_t

  opts = opts or {}

  opts.prompt = opts.prompt and vim.trim(opts.prompt:gsub(":%s*$", ""))

  local virt_text_pat = "%((.*)%)%s*%.?%s*$"
  if opts.kind == "legendary.nvim" then
    virt_text_pat = "^%s*([^│]*│[^|]*)%s*│%s*"
    -- elseif opts.kind == "resession_load" then
    --   virt_text_pat = "%s*%[([^%]]+)%]%s*$"
  end

  local entries = vim
    .iter(items)
    :enumerate()
    :map(function(idx, item)
      local text = item
      if opts.format_item then
        text = opts.format_item(item)
      end
      local virt_text
      if text:match(virt_text_pat) then
        virt_text = text:match(virt_text_pat)
        text = text:gsub(virt_text_pat, "")
      end
      return dropbar_menu_entry_t:new({
        virt_text = virt_text
          and { { " ", "NormalFloat" }, { virt_text, "Comment" } },
        components = {
          dropbar_symbol_t:new({
            icon = " ",
            icon_hl = "Special",
            name = text,
            preview = function(self)
              if opts.preview then
                opts.preview(self, item, idx)
              end
            end,
            preview_restore_view = function(self)
              if opts.preview_restore_view then
                opts.preview_restore_view(self, item, idx)
              end
            end,
            preview_restore_hl = function(self)
              if opts.preview_restore_hl then
                opts.preview_restore_hl(self, item, idx)
              end
            end,
            on_click = function(self)
              self.entry.menu:close()
              vim.schedule(function()
                if on_choice then
                  on_choice(item, idx)
                end
              end)
            end,
          }),
        },
      })
    end)
    :totable()

  local function virt_text_width(chunks)
    local total = 0
    for _, chunk in ipairs(chunks) do
      total = total + vim.fn.strcharlen(chunk[1])
    end
    return total
  end

  local width = math.min(
    math.max(
      vim
        .iter(entries)
        :map(function(entry)
          return math.max(
            entry:displaywidth(),
            entry.virt_text and (virt_text_width(entry.virt_text) + 2) or 0
          )
        end)
        :fold(0, math.max),
      opts.prompt and (vim.fn.strcharlen(opts.prompt) + 2) or 0,
      16
    ),
    math.max(math.floor(vim.o.columns / 2), math.floor(vim.o.columns - 30))
  )

  local height_unclamped = 0
  for _, entry in ipairs(entries) do
    height_unclamped = height_unclamped + (entry.virt_text and 2 or 1)
  end
  local height = math.min(12, math.max(height_unclamped, 3))

  local menu = dropbar_menu_t:new({
    entries = entries,
    prev_win = vim.api.nvim_get_current_win(),
    win_configs = {
      relative = "cursor",
      title = opts.prompt,
      row = 1,
      col = 1,
      width = width,
      height = height,
      border = opts.prompt and {
        " ",
        " ",
        " ",
        "",
        " ",
        " ",
        " ",
        "",
      },
      title_pos = opts.prompt and "center",
    },
  })

  menu:open()

  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = menu.buf,
    callback = function()
      local cursor = vim.api.nvim_win_get_cursor(menu.win)
      local eventignore = vim.o.eventignore
      vim.o.eventignore = "all"
      vim.api.nvim_win_set_cursor(menu.win, {
        cursor[1],
        1,
      })
      menu:update_hover_hl({ cursor[1], 1 })
      vim.o.eventignore = eventignore
    end,
  })
end

M.setup = function()
  vim.ui.select = M.ui_select
end

return setmetatable(M, {
  __call = function(_, ...)
    M.ui_select(...)
  end,
})
