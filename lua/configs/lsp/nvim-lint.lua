local lint = require("lint")

lint.linters_by_ft = {
  -- lua = { "selene" },
  proto = { "protolint" },
  markdown = { "markdownlint" },
  zsh = { "shellcheck" },
  json = { "jsonlint" },
}

local group =
  vim.api.nvim_create_augroup("willothy.nvim-lint", { clear = true })

vim.api.nvim_create_autocmd({
  "TextChangedI",
  "InsertLeave",
}, {
  group = group,
  callback = willothy.fn.debounce_trailing(function()
    lint.try_lint()
  end, 1000),
})

vim.api.nvim_create_autocmd({
  "TextChanged",
  "BufWritePost",
}, {
  group = group,
  callback = function()
    lint.try_lint()
  end,
})
