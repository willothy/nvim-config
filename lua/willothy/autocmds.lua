vim.api.nvim_create_autocmd({
  "TermResponse",
}, {
  callback = function()
    vim.cmd("checktime")
  end,
})
