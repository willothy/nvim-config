local harpoon = require("harpoon")

harpoon:setup({
  settings = {
    save_on_toggle = true,
    -- sync_on_ui_close = true,
    -- save_on_change = true,
    key = function()
      return vim.uv.cwd() --[[@as string]]
    end,
  },
  default = {
    prepopulate = function()
      local Path = require("plenary.path")
      local cwd = vim.uv.cwd()
      local limit = 3
      return vim
        .iter(require("mini.visits").list_paths())
        :enumerate()
        :filter(function(i)
          return i <= limit
        end)
        :map(function(_, path)
          local p = Path:new(path):make_relative(cwd)
          local buf = vim.fn.bufnr(p, false)
          local row, col = 1, 1
          if buf and vim.api.nvim_buf_is_valid(buf) then
            if not vim.api.nvim_buf_is_loaded(buf) then
              vim.fn.bufload(buf)
            end
            row, col = unpack(vim.api.nvim_buf_get_mark(buf, '"'))
          end
          return {
            value = p,
            context = {
              row = row,
              col = col,
            },
          }
        end)
        :totable()
    end,
  },
})

local Path = require("plenary.path")
local fidget = require("fidget")

local titles = {
  ADD = "added",
  REMOVE = "removed",
}

local function notify(event, cx)
  local path = Path:new(cx.item.value) --[[@as Path]]

  local display = path:make_relative(vim.uv.cwd())
    or path:make_relative(vim.env.HOME)
    or path:normalize()

  fidget.progress.handle.create({
    lsp_client = {
      name = "harpoon",
    },
    title = titles[event],
    message = display,
    level = vim.log.levels.ERROR,
  })
end

harpoon.listeners:add_listener("ADD", notify)
harpoon.listeners:add_listener("REMOVE", notify)
harpoon.listeners:add_listener("UI_CREATE", function(_, cx)
  vim.keymap.set("n", "<C-v>", function()
    harpoon.ui:select_menu_item({ vsplit = true })
  end, { buffer = cx.bufnr })
  vim.keymap.set("n", "<C-s>", function()
    harpoon.ui:select_menu_item({ split = true })
  end, { buffer = cx.bufnr })
end)
