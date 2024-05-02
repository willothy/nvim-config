local opts = {
  formatters_by_ft = {
    lua = { "stylua" },
    c = { { "uncrustify", "clang_format" } },
    cpp = { "clang_format" },
    cuda = { "clang_format" },
    rust = { "rustfmt" },
    javascript = { { "prettier" } },
    typescript = { { "prettier" } },
    typescriptreact = { { "prettier" } },
    tsx = { { "prettier" } },
    css = { { "prettier" } },
    scss = { { "prettier" } },
    html = { { "prettier" } },
    markdown = { { "markdownlint", "prettier" } },
    json = { { "jq", "prettier" } },
    proto = { { "buf", "protolint" } },
    nasm = { { "asmfmt" } },
    asm = { { "asmfmt" } },
    nix = { { "nixpkgs_fmt" } },
    just = { "just" },
    python = { "black" },
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

conform.formatters.uncrustify = {
  meta = {
    url = "https://github.com/uncrustify/uncrustify",
    description = "A source code beautifier for C, C++, C#, ObjectiveC, D, Java, Pawn and Vala.",
  },
  command = "uncrustify",
  args = function(self, ctx)
    return {
      "-q",
      "-l",
      vim.bo[ctx.buf].filetype:upper(),
      "-c",
      vim.uv.cwd() .. "/src/uncrustify.cfg",
    }
  end,
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
