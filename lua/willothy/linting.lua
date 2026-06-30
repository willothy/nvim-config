local lint = require("lint")

lint.linters_by_ft = {
  -- lua = { "selene" },
  -- proto = { "protolint" },
  markdown = { "markdownlint" },
  zsh = { "shellcheck" },
  json = { "jsonlint" },
}

local group =
  vim.api.nvim_create_augroup("willothy.nvim-lint", { clear = true })

-- Coalesce lint runs from editing: every TextChanged (incl. normal-mode edits
-- like dd/ciw/paste/undo and macros) and TextChangedI fires this, but
-- try_lint() spawns external linter processes, so debounce instead of spawning
-- one per change. A single shared debouncer also coalesces across all three
-- editing events.
local debounced_lint = require("willothy.lib.fn").debounce_trailing(function()
  lint.try_lint()
end, 1000)

vim.api.nvim_create_autocmd({
  "TextChanged",
  "TextChangedI",
  "InsertLeave",
}, {
  group = group,
  callback = debounced_lint,
})

-- Lint immediately on save so results are fresh right after writing.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  callback = function()
    lint.try_lint()
  end,
})
