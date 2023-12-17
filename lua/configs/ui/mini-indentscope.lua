local cached_hl = {}
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "IndentScope", cached_hl)
  end,
})

require("ibl").setup({
  indent = {
    -- highlight = "IndentScope",
    highlight = "IndentScope",
    char = "▏",
  },
  whitespace = {
    highlight = "IndentScope",
  },
  scope = { enabled = false },
})

cached_hl = vim.api.nvim_get_hl(0, {
  name = "IndentScope",
  link = false,
  create = false,
})

require("mini.indentscope").setup({
  draw = {
    delay = 40,
    priority = 20,
    animation = require("mini.indentscope").gen_animation.linear({
      easing = "in",
      duration = 40,
      unit = "step",
    }),
  },
  symbol = "▏",
  options = {
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
vim.api.nvim_create_autocmd({ "FileType", "BufNew" }, {
  pattern = "*",
  callback = function()
    if disabled[vim.bo.filetype] ~= nil or vim.bo.buftype ~= "" then
      vim.b.miniindentscope_disable = true
    end
  end,
})
