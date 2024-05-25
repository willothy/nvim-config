local null_ls = require("null-ls")
local builtins = null_ls.builtins

null_ls.setup({
  sources = {
    builtins.code_actions.refactoring,
    builtins.code_actions.gitrebase,
    builtins.hover.dictionary,
    builtins.hover.printenv,
    builtins.diagnostics.buf.with({
      args = { "lint" },
    }),
  },
  should_attach = function(bufnr)
    local ignored = {
      "TelescopePrompt",
      "neo-tree",
      "SidebarNvim",
      "Undotree",
      "NvimTree",
      "lazy",
      "terminal",
    }
    if not vim.bo[bufnr].buflisted then
      return false
    end
    local win = vim.fn.bufwinid(bufnr)
    if vim.wo[win].diff then
      return false
    end
    if vim.bo[bufnr].buftype ~= "" then
      return false
    end
    if ignored[vim.bo[bufnr].filetype] then
      return false
    end
    return true
  end,
})
