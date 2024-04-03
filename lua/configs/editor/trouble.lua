local trouble = require("trouble")

trouble.setup({
  pinned = false,
  focus = true,
  follow = true,
  restore = true,
  win = {
    type = "split",
    wo = {
      fillchars = vim.o.fillchars,
      cursorlineopt = "number",
      concealcursor = "nvic",
    },
  },
  indent_guides = true,
  multiline = true,
  preview = {
    type = "main",
    zindex = 50,
    wo = {
      -- winbar = "",
      statuscolumn = "%!v:lua.StatusCol()",
      list = true,
      number = true,
      relativenumber = false,
    },
  },
  modes = {
    definitions2 = {
      mode = "lsp_definitions",
      focus = true,
      sections = {
        ["lsp_definitions"] = {
          title = "LSP Definitions",
          icon = "",
          highlight = "TroubleLspDef",
          indent = 1,
        },
      },
    },
  },
})

local Window = require("trouble.view.window")

local mount_float = Window.mount_float
---@diagnostic disable-next-line: duplicate-set-field
function Window:mount_float(opts)
  if self.opts.type ~= "main" then
    return mount_float(self, opts)
  end
  local main = require("trouble.view.main").get().win

  self.win = main

  ---@diagnostic disable-next-line: duplicate-set-field
  self.close = function()
    self:augroup(true)
    self.win = nil
  end
end

local preview = require("trouble.view.preview")

local preview_open = preview.open
---@diagnostic disable-next-line: duplicate-set-field
function preview.open(view, item)
  local res = preview_open(view, item)

  require("dropbar.utils.bar")
    .get({
      win = preview.preview.win,
    })
    :update()

  return res
end

local v

local preview_win = preview.preview_win
---@diagnostic disable-next-line: duplicate-set-field
function preview.preview_win(buf, view)
  if view.opts.preview.type == "main" then
    local win = require("trouble.view.main").get().win
    v = v
      or vim.api.nvim_win_call(win, function()
        return vim.fn.winsaveview()
      end)
    return {
      win = win,
      close = function()
        if v then
          vim.api.nvim_win_call(win, function()
            vim.fn.winrestview(v)
          end)
          v = nil
        end
        view.preview_win:close()
      end,
    }
  else
    return preview_win(buf, view)
  end
end

vim.api.nvim_set_hl(0, "TroubleNormalNC", {
  link = "TroubleNormal",
})
