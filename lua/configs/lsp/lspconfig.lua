local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

capabilities.textDocument.formatting = {
  dynamicRegistration = false,
}

capabilities.textDocument.semanticTokens.augmentsSyntaxTokens = false

capabilities.textDocument.completion.completionItem = {
  contextSupport = true,
  snippetSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
  labelDetailsSupport = true,
  documentationFormat = { "markdown", "plaintext" },
}

-- send actions with hover request
capabilities.experimental = {
  hoverActions = true,
  hoverRange = true,
  serverStatusNotification = true,
  -- snippetTextEdit = true, -- not supported yet
  codeActionGroup = true,
  ssr = true,
  commands = {
    "rust-analyzer.runSingle",
    "rust-analyzer.debugSingle",
    "rust-analyzer.showReferences",
    "rust-analyzer.gotoLocation",
    "editor.action.triggerParameterHints",
  },
}

-- capabilities = require("blink.cmp").get_lsp_capabilities(capabilities, false)

local icons = willothy.ui.icons

require("mason").setup()

local lspconfig = require("lspconfig")

local neoconf = require("neoconf")
neoconf.setup({})

local function settings(server, default)
  return neoconf.get("lspconfig." .. server, default or {}, { lsp = true })
end

-- require("neodev").setup({
--   lspconfig = false,
--   pathStrict = true,
-- })

lspconfig.rust_analyzer.setup({
  capabilities = capabilities,
  root_dir = require("lspconfig.util").root_pattern(".git", "Cargo.toml"),
  settings = settings("rust_analyzer"),
  offsetEncoding = { "utf-8" },
  client_encoding = "utf-8",
  single_file_support = true,
})

lspconfig.clangd.setup({
  capabilities = capabilities,
  settings = settings("clangd"),
  on_attach = function(_client, bufnr)
    vim.keymap.set("n", "<leader>gh", "<cmd>ClangdSwitchSourceHeader<CR>", {
      silent = true,
      noremap = true,
      buffer = bufnr,
      desc = "header / source",
    })
  end,
  root_dir = require("lspconfig.util").root_pattern(".git"),
  filetypes = { "c", "cpp", "h", "hpp" },
  offsetEncoding = { "utf-8" },
  client_encoding = "utf-8",
})

local rename = {
  tsserver = "ts_ls",
}

require("mason-lspconfig").setup({
  handlers = {
    function(server_name)
      lspconfig[rename[server_name] or server_name].setup({
        capabilities = capabilities,
        settings = settings(rename[server_name] or server_name),
        root_dir = require("lspconfig.util").root_pattern(
          ".git",
          "package.json"
        ),
      })
    end,
    gopls = function()
      lspconfig.gopls.setup({
        capabilities = capabilities,
        settings = settings("gopls"),
        root_dir = require("lspconfig.util").root_pattern(".git", "go.mod"),
      })
    end,
    clangd = function() end,
    rust_analyzer = function() end,
    taplo = function()
      lspconfig.taplo.setup({
        capabilities = capabilities,
        settings = settings("taplo"),
        root_dir = require("lspconfig.util").root_pattern(
          ".git",
          "Cargo.toml",
          "~/.config/*"
        ),
      })
    end,
    basedpyright = function()
      lspconfig.basedpyright.setup({
        capabilities = capabilities,
        settings = settings("basedpyright"),
        root_dir = require("lspconfig.util").root_pattern(
          "pyproject.toml",
          ".git"
        ),
      })
    end,
    bashls = function()
      lspconfig.bashls.setup({
        capabilities = capabilities,
        settings = settings("bashls"),
        filetypes = { "zsh", "sh", "bash" },
        root_dir = require("lspconfig.util").root_pattern(".git", ".zshrc"),
      })
    end,
    bufls = function()
      lspconfig.bufls.setup({
        capabilities = capabilities,
        filetypes = { "proto" },
        settings = settings("bufls"),
        root_dir = require("lspconfig.util").root_pattern(".git"),
      })
    end,
    intelephense = function()
      lspconfig.intelephense.setup({
        settings = settings("intelephense"),
        capabilities = capabilities,
        root_dir = require("lspconfig.util").root_pattern(".git"),
      })
    end,
  },
})

lspconfig.lua_ls.setup({
  capabilities = capabilities,
  root_dir = require("lspconfig.util").root_pattern(".git"),
  settings = require("neoconf").get("lspconfig.lua_ls", {
    Lua = {},
  }, {
    lsp = true,
  }),
  -- before_init = function(params, config)
  --   local libs = config.settings.Lua.workspace.library
  --
  --   for _, lib in ipairs({
  --     -- "${3rd}/busted/library",
  --     "${3rd}/luv/library",
  --   }) do
  --     table.insert(libs, lib)
  --   end
  --
  --   return require("neodev.lsp").before_init(params, config)
  -- end,
  single_file_support = false,
  filetypes = { "lua" },
})

for nvim_name, trouble_name in pairs({
  references = "lsp_references",
  definition = "lsp_definitions",
  type_definition = "lsp_type_definitions",
  implementation = "lsp_implementations",
  document_symbol = "lsp_document_symbols",
}) do
  vim.lsp.buf[nvim_name] = function()
    require("trouble").open({
      mode = trouble_name,
    })
  end
end

local signs = {
  DapBreakpoint = {
    text = icons.dap.breakpoint.data,
    icon = icons.dap.breakpoint.data,
    texthl = "DiagnosticSignError",
  },
  DapBreakpointCondition = {
    text = icons.dap.breakpoint.conditional,
    icon = icons.dap.breakpoint.conditional,
    texthl = "DiagnosticSignWarn",
  },
  DapLogPoint = {
    text = icons.dap.breakpoint.log,
    icon = icons.dap.breakpoint.log,
    texthl = "DiagnosticSignInfo",
  },
  DapStopped = {
    text = icons.dap.action.stop,
    icon = icons.dap.action.stop,
    texthl = "DiagnosticSignInfo",
  },
  DapBreakpointRejected = {
    text = icons.dap.breakpoint.unsupported,
    icon = icons.dap.breakpoint.unsupported,
    texthl = "DiagnosticSignWarn",
  },
}

for name, def in pairs(signs) do
  vim.fn.sign_define(name, def)
end

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = true,
  underline = true,
  -- warden = {
  --   line_highlight = true,
  -- },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
    },
  },
  float = {
    header = setmetatable({}, {
      __index = function(_, k)
        local arr = {
          string.format(
            "Diagnostics: %s %s",
            require("nvim-web-devicons").get_icon_by_filetype(vim.bo.filetype),
            vim.bo.filetype
          ),
          "Title",
        }
        return arr[k]
      end,
    }),
    source = true,
    border = "solid",
    focusable = false,
  },
})
