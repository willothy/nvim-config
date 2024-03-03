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

-- TODO: replace rust-tools as it is no longer maintained
-- require("rust-tools").setup({
--   executor = {
--     execute_command = function(command, args, cwd)
--       require("overseer.task")
--         .new({
--           cmd = { command, unpack(args) },
--           cwd = cwd,
--         })
--         :start()
--     end,
--   },
--   tools = {
--     inlay_hints = {
--       auto = false,
--     },
--     hover_actions = {
--       border = "solid",
--     },
--   },
--   server = {
--     on_attach = lsp_attach,
--     root_dir = require("lspconfig.util").root_pattern(".git", "Cargo.toml"),
--   },
-- })

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
        root_dir = require("lspconfig.util").root_pattern(".git"),
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
    lua_ls = function()
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

vim.lsp.handlers["textDocument/references"] = function()
  require("trouble").open("lsp_references")
end

vim.lsp.handlers["textDocument/definition"] = function()
  require("trouble").open("lsp_definitions")
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
          function()
            return string.format(
              "diagnostics: %s %s",
              require("nvim-web-devicons").get_icon_by_filetype(
                vim.bo.filetype
              ),
              vim.bo.filetype
            )
          end,
          function()
            return "Title"
          end,
        }
        return arr[k]()
      end,
    }),
    source = "always",
    border = "solid",
    focusable = false,
  },
})
