local null_ls = require("null-ls")
local builtins = null_ls.builtins

null_ls.setup({
  sources = {
    -- null_ls.builtins.formatting.protolint,
    -- null_ls.builtins.diagnostics.protolint,
    -- builtins.formatting.markdownlint,
    -- builtins.formatting.taplo,
    -- builtins.diagnostics.commitlint,
    -- builtins.diagnostics.markdownlint,
    -- builtins.diagnostics.semgrep,
    -- builtins.diagnostics.shellcheck,
    -- builtins.diagnostics.zsh,
    builtins.code_actions.refactoring,
    builtins.code_actions.gitrebase,
    -- builtins.code_actions.ts_node_action,
    -- builtins.code_actions.gitsigns,
    builtins.code_actions.eslint,
    builtins.hover.dictionary,
    builtins.hover.printenv,
  },
  on_attach = require("configs.lsp").lsp_attach,
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
