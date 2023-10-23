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
    json = { { "jq", "prettierd", "prettier" } },
    proto = { { "buf", "protolint" } },
  },
  -- format_on_save = {
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
  format_on_save = function(bufnr)
    -- Disable with a global or buffer-local variable
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 500, lsp_fallback = true }
  end,
}

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

local conform = require("conform")

conform.setup(opts)

conform.formatters.rustfmt = {
  meta = {
    url = "https://github.com/rust-lang/rustfmt",
    description = "A tool for formatting rust code according to style guidelines.",
  },
  command = "rustfmt",
  args = { "--emit=stdout", "--edition=2021" },
}

willothy.fn.create_command("Format", {
  desc = "Manage formatting",
  bang = true,
  command = function()
    require("conform").format({
      lsp_fallback = true,
    })
  end,
  subcommands = {
    disable = {
      execute = function()
        vim.g.disable_autoformat = true
      end,
    },
    enable = {
      execute = function()
        vim.g.disable_autoformat = false
      end,
    },
    toggle = {
      execute = function()
        vim.g.disable_autoformat = not vim.g.disable_autoformat
      end,
    },
  },
})
