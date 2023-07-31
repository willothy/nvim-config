require("mini.indentscope").setup({
  symbol = "▏",
  options = {
    -- border = "bottom",
    try_as_border = true,
  },
  mappings = {
    goto_top = "",
    goto_bottom = "",
    object_scope = "",
    object_scope_with_border = "",
  },
})
local disabled = {
  "harpoon",
  "help",
  "terminal",
}
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    if disabled[vim.bo.filetype] ~= nil or vim.bo.buftype ~= "" then
      vim.b.miniindentscope_disable = true
    end
  end,
})
