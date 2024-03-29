require("otter").setup({
  set_filetype = true,
})

local otter = require("otter")

vim.g.markdown_fenced_languages = {
  "lua",
  "rust",
}

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "*.md" },
  callback = function()
    otter.activate({ "rust", "lua" }, true)
    vim.api.nvim_buf_set_keymap(
      0,
      "n",
      "gd",
      ":lua require'otter'.ask_definition()<cr>",
      { silent = true }
    )
    vim.api.nvim_buf_set_keymap(
      0,
      "n",
      "K",
      ":lua require'otter'.ask_hover()<cr>",
      { silent = true }
    )
  end,
})
