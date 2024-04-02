local M = {}

local augroup

---@class Willothy.Highlight
---@field fg? string
---@field bg? string
---@field sp? string
---@field bold? boolean
---@field italic? boolean
---@field underline? boolean
---@field undercurl? boolean
---@field strikethrough? boolean

function M.update()
  --
end

function M.setup()
  augroup = vim.api.nvim_create_augroup("willothy/ui/colors", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = vim.schedule_wrap(M.update),
    desc = "Update plugin hlgroups on colorscheme change",
  })
end

return M
