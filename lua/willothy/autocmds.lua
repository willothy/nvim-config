local group =
  vim.api.nvim_create_augroup("willothy.autocmds", { clear = true })

vim.api.nvim_create_autocmd({
  "CursorHold",
  "CursorHoldI",
}, {
  group = group,
  callback = function()
    vim.lsp.buf.document_highlight()
  end,
})

vim.api.nvim_create_autocmd({
  "CursorMoved",
  "CursorMovedI",
}, {
  group = group,
  callback = function()
    vim.lsp.buf.clear_references()
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  callback = function()
    require("mini.trailspace").trim()
  end,
})

vim.api.nvim_create_autocmd({
  "TermResponse",
}, {
  group = group,
  callback = function()
    vim.cmd("checktime")
  end,
})
