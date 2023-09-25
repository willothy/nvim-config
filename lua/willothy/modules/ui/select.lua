--- UI select module using Dropbar.nvim

local M = {}

function M.ui_select(items, opts, on_choice)
  if not items then
    return
  end

  local dropbar_menu_t = require("dropbar.menu").dropbar_menu_t
  local dropbar_menu_entry_t = require("dropbar.menu").dropbar_menu_entry_t
  local dropbar_symbol_t = require("dropbar.bar").dropbar_symbol_t

  opts = opts or {}

  opts.prompt = opts.prompt and vim.trim(opts.prompt:gsub(":$", ""))

  local entries = vim
    .iter(items)
    :enumerate()
    :map(function(idx, item)
      local text = item
      if opts.format_item then
        text = opts.format_item(item)
      end
      local virt_text
      if text:match("%(.*%)%s*$") then
        virt_text = text:match("%((.*)%)")
        text = text:gsub("%(.*%)%s*$", "")
      end
      return dropbar_menu_entry_t:new({
        virt_text = virt_text
          and { { " ", "NormalFloat" }, { virt_text, "Comment" } },
        components = {
          dropbar_symbol_t:new({
            icon = " ",
            icon_hl = "Special",
            name = text,
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
    math.floor(vim.o.columns / 2)
  )

  local height = math.max(
    vim.iter(entries):fold(0, function(acc, entry)
      return acc + (entry.virt_text and 2 or 1)
    end),
    3
  )

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
end

M.setup = function()
  vim.ui.select = M.ui_select
end

return setmetatable(M, {
  __call = function(_, ...)
    M.ui_select(...)
  end,
})
