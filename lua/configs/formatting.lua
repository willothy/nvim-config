local opts = {
  formatters_by_ft = {
    -- sql = {
    --   stop_after_first = true,
    --   "sqlfmt",
    -- },
    lua = {
      stop_after_first = true,
      "stylua",
    },
    c = {
      stop_after_first = true,
      "uncrustify",
      "clang_format",
    },
    cpp = {
      stop_after_first = true,
      "clang_format",
    },
    cuda = {
      stop_after_first = true,
      "clang_format",
    },
    rust = {
      stop_after_first = true,
      "rustfmt",
    },
    javascript = {
      stop_after_first = true,
      "prettier",
    },
    typescript = {
      stop_after_first = true,
      "prettier",
    },
    typescriptreact = {
      stop_after_first = true,
      "prettier",
    },
    tsx = {
      stop_after_first = true,
      "prettier",
    },
    css = {
      stop_after_first = true,
      "prettier",
    },
    scss = {
      stop_after_first = true,
      "prettier",
    },
    html = {
      stop_after_first = true,
      "prettier",
    },
    markdown = {
      stop_after_first = true,
      "markdownlint",
      "prettier",
    },
    json = {
      stop_after_first = true,
      "jq",
      "prettier",
    },
    toml = {
      stop_after_first = true,
      "taplo",
      "prettier",
    },
    jsonc = {
      stop_after_first = true,
      "jq",
      "prettier",
    },
    proto = {
      stop_after_first = true,
      "buf",
      "protolint",
    },
    nasm = {
      stop_after_first = true,
      "asmfmt",
    },
    asm = {
      stop_after_first = true,
      "asmfmt",
    },
    nix = {
      stop_after_first = true,
      "nixpkgs_fmt",
    },
    just = { "just" },
    -- python = { "black" },
    python = { "blue" },
    bzl = { "buildifier" },
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

require("willothy.lib.fn").create_command("Format", {
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
