if vim.g.minimal ~= nil then
  require("willothy.minimal")
  return
end

_G.dbg = vim.print

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("willothy.util")
require("willothy.lazy")
require("willothy.set")

vim.api.nvim_create_autocmd("UiEnter", {
  once = true,
  callback = function() require("willothy.mappings") end,
})

-- require("willothy.ui")

-- setup float dragging
-- require("willothy.ui").setup({
--   resize = "<S-LeftDrag>",
-- })

-- vim.api.nvim_create_user_command("Detach", function()
--   local uis = vim.api.nvim_list_uis()
--   if #uis < 1 then return end
--   local chan = uis[1].chan
--   vim.fn.chanclose(chan)
-- end, {})
