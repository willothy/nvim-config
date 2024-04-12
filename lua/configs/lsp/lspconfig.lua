-- auto-create nested tables
local mt
mt = {
  __index = function(self, k)
    local v = setmetatable({}, mt)
    self[k] = v
    return v
  end,
}

---@type lsp.ClientCapabilities
local capabilities = setmetatable({}, mt)

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

local default_capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities = vim.tbl_deep_extend("force", default_capabilities, capabilities)

local icons = willothy.ui.icons
require("mason").setup()

local lspconfig = require("lspconfig")

require("neoconf").setup({})

require("neodev").setup({
  lspconfig = false,
  pathStrict = true,
})

lspconfig.rust_analyzer.setup({
  capabilities = capabilities,
  root_dir = require("lspconfig.util").root_pattern(".git", "Cargo.toml"),
  offsetEncoding = { "utf-8" },
  client_encoding = "utf-8",
  single_file_support = true,
})

require("mason-lspconfig").setup({
  handlers = {
    function(server_name)
      lspconfig[server_name].setup({
        capabilities = capabilities,
        root_dir = require("lspconfig.util").root_pattern(
          ".git",
          "package.json"
        ),
      })
    end,
    clangd = function()
      lspconfig.clangd.setup({
        capabilities = capabilities,
        on_attach = function(_client, bufnr)
          vim.keymap.set(
            "n",
            "<leader>gh",
            "<cmd>ClangdSwitchSourceHeader<CR>",
            {
              silent = true,
              noremap = true,
              buffer = bufnr,
              desc = "header / source",
            }
          )
        end,
        root_dir = require("lspconfig.util").root_pattern(".git"),
        filetypes = { "c", "cpp", "h", "hpp" },
        offsetEncoding = { "utf-8" },
        client_encoding = "utf-8",
      })
    end,
    taplo = function()
      lspconfig.taplo.setup({
        capabilities = capabilities,
        root_dir = require("lspconfig.util").root_pattern(
          ".git",
          "Cargo.toml",
          "~/.config/*"
        ),
      })
    end,
    bashls = function()
      require("lspconfig").bashls.setup({
        capabilities = capabilities,
        filetypes = { "zsh", "sh", "bash" },
        root_dir = require("lspconfig.util").root_pattern(".git", ".zshrc"),
      })
    end,
    intelephense = function()
      lspconfig.intelephense.setup({
        capabilities = capabilities,
        root_dir = require("lspconfig.util").root_pattern(".git"),
      })
    end,
  },
})

lspconfig.lua_ls.setup({
  capabilities = capabilities,
  root_dir = require("lspconfig.util").root_pattern(".git"),
  before_init = function(params, config)
    local libs = config.settings.Lua.workspace.library

    for _, lib in ipairs({
      -- "${3rd}/busted/library",
      "${3rd}/luv/library",
    }) do
      table.insert(libs, lib)
    end

    return require("neodev.lsp").before_init(params, config)
  end,
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
  warden = {
    line_highlight = true,
  },
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
