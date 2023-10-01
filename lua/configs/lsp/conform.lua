local opts = {
  formatters_by_ft = {
    lua = { "stylua" },
    c = { "clang_format" },
    cpp = { "clang_format" },
    rust = { "rustfmt" },
    javascript = { { "prettierd", "prettier" } },
    typescript = { { "prettierd", "prettier" } },
    css = { { "prettierd", "prettier" } },
    scss = { { "prettierd", "prettier" } },
    html = { { "prettierd", "prettier" } },
    markdown = { { "markdownlint", "prettierd", "prettier" } },
    toml = { { "prettierd", "prettier" } },
    json = { { "jq", "prettierd", "prettier" } },
    proto = { { "buf", "protolint" } },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

require("conform").setup(opts)
