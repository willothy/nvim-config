local null_ls = require("null-ls")
local builtins = null_ls.builtins

null_ls.setup({
  sources = {
    builtins.formatting.stylua,
    -- builtins.diagnostics.selene,
    builtins.formatting.prettier.with({
      filetypes = {
        "toml",
        "js",
        "ts",
        "javascript",
        "typescript",
        "scss",
        "css",
        -- "html",
        "json",
        "markdown",
      },
    }),
    builtins.formatting.rustfmt,
    builtins.formatting.asmfmt,
    builtins.formatting.beautysh,
    builtins.formatting.clang_format.with({
      filetypes = { "c", "cpp" },
    }),
    null_ls.builtins.diagnostics.protolint,
    null_ls.builtins.formatting.protolint,
    -- builtins.formatting.markdownlint,
    builtins.formatting.taplo,
    -- builtins.diagnostics.commitlint,
    builtins.diagnostics.markdownlint,
    -- builtins.diagnostics.semgrep,
    -- builtins.diagnostics.shellcheck,
    builtins.diagnostics.zsh,
    builtins.code_actions.gitrebase,
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
