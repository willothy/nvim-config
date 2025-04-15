return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  settings = {
    -- typescript = {
    --   inlayHints = {
    --     includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
    --     includeInlayParameterNameHintsWhenArgumentMatchesName = true,
    --     includeInlayVariableTypeHints = true,
    --     includeInlayFunctionParameterTypeHints = true,
    --     includeInlayVariableTypeHintsWhenTypeMatchesName = true,
    --     includeInlayPropertyDeclarationTypeHints = true,
    --     includeInlayFunctionLikeReturnTypeHints = true,
    --     includeInlayEnumMemberValueHints = true,
    --   },
    -- },
    -- javascript = {
    --   inlayHints = {
    --     includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
    --     includeInlayParameterNameHintsWhenArgumentMatchesName = true,
    --     includeInlayVariableTypeHints = true,
    --     includeInlayFunctionParameterTypeHints = true,
    --     includeInlayVariableTypeHintsWhenTypeMatchesName = true,
    --     includeInlayPropertyDeclarationTypeHints = true,
    --     includeInlayFunctionLikeReturnTypeHints = true,
    --     includeInlayEnumMemberValueHints = true,
    --   },
    -- },
  },
  init_options = {
    hostInfo = "neovim",
  },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  single_file_support = true,
}
