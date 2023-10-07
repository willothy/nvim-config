local function mkcaps(extra)
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  if extra then
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }

    -- send actions with hover request
    capabilities.experimental = {
      hoverActions = true,
      hoverRange = true,
      serverStatusNotification = true,
      snippetTextEdit = true,
      codeActionGroup = true,
      ssr = true,
    }

    capabilities.textDocument.formatting = {
      dynamicRegistration = false,
    }
  end

  ---@diagnostic disable-next-line: missing-fields
  capabilities.textDocument.semanticTokens = {
    augmentsSyntaxTokens = false,
  }

  return capabilities
end

local icons = willothy.icons
require("mason").setup()

local lspconfig = require("lspconfig")
local capabilities = mkcaps(true)

local lsp_attach = require("configs.lsp").lsp_attach

require("neoconf").setup({})

require("rust-tools").setup({
  executor = {
    execute_command = function(command, args, cwd)
      require("overseer.task")
        .new({
          cmd = { command, unpack(args) },
          cwd = cwd,
        })
        :start()
    end,
  },
  tools = {
    inlay_hints = {
      auto = false,
    },
    hover_actions = {
      border = {
        -- { "▄", "NormalFloatInv" }, -- top left
        -- { "▄", "NormalFloatInv" }, -- top
        -- { "▄", "NormalFloatInv" }, -- top right
        -- { " ", "NormalFloatInv" }, -- right
        -- { "▀", "NormalFloatInv" }, -- bottom right
        -- { "▀", "NormalFloatInv" }, -- bottom
        -- { "▀", "NormalFloatInv" }, -- bottom left
        -- { " ", "NormalFloatInv" }, -- left
        { " ", "NormalFloat" }, -- top left
        { " ", "NormalFloat" }, -- top
        { " ", "NormalFloat" }, -- top right
        { " ", "NormalFloat" }, -- right
        { " ", "NormalFloat" }, -- bottom right
        { " ", "NormalFloat" }, -- bottom
        { " ", "NormalFloat" }, -- bottom left
        { " ", "NormalFloat" }, -- left
      },
    },
  },
  server = {
    on_attach = lsp_attach,
    root_dir = require("lspconfig.util").root_pattern(".git", "Cargo.toml"),
  },
})

require("neodev").setup({
  lspconfig = true,
  pathStrict = true,
  library = {
    types = false,
  },
})
lspconfig.lua_ls.setup({
  capabilities = capabilities,
  on_attach = lsp_attach,
  root_dir = require("lspconfig.util").root_pattern(".git"),
  before_init = require("neodev.lsp").before_init,
  single_file_support = true,
  filetypes = { "lua" },
})

require("mason-lspconfig").setup({
  handlers = {
    function(server_name)
      lspconfig[server_name].setup({
        capabilities = capabilities,
        on_attach = lsp_attach,
        root_dir = require("lspconfig.util").root_pattern(".git"),
      })
    end,
    clangd = function()
      lspconfig.clangd.setup({
        capabilities = capabilities,
        on_attach = lsp_attach,
        root_dir = require("lspconfig.util").root_pattern(".git"),
        filetypes = { "c", "cpp", "h", "hpp" },
      })
    end,
    taplo = function()
      lspconfig.taplo.setup({
        capabilities = capabilities,
        on_attach = lsp_attach,
        root_dir = require("lspconfig.util").root_pattern(
          ".git",
          "Cargo.toml",
          "~/.config/*"
        ),
      })
    end,
    lua_ls = function() end,
    bashls = function()
      require("lspconfig").bashls.setup({
        capabilities = mkcaps(false),
        attach = lsp_attach,
        filetypes = { "zsh", "sh", "bash" },
        root_dir = require("lspconfig.util").root_pattern(".git", ".zshrc"),
      })
    end,
    intelephense = function()
      lspconfig.intelephense.setup({
        capabilities = capabilities,
        on_attach = lsp_attach,
        root_dir = require("lspconfig.util").root_pattern(".git"),
      })
    end,
  },
})

-- vim.lsp.buf.references
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.handlers["textDocument/references"] = function()
  require("trouble").open("lsp_references")
end

vim.lsp.handlers["textDocument/definition"] = function()
  require("trouble").open("lsp_definitions")
end

local sign = function(opts)
  vim.fn.sign_define(opts.name, {
    texthl = opts.hl or opts.name,
    icon = opts.text,
    text = opts.text,
  })
end

sign({ name = "DiagnosticSignError", text = icons.diagnostics.errors })
sign({ name = "DiagnosticSignWarn", text = icons.diagnostics.warnings })
sign({ name = "DiagnosticSignHint", text = icons.diagnostics.hints })
sign({ name = "DiagnosticSignInfo", text = icons.diagnostics.info })
sign({
  name = "LightBulbSign",
  text = icons.lsp.action_hint,
  hl = "DiagnosticSignWarn",
})
sign({
  name = "DapBreakpoint",
  text = icons.dap.breakpoint.data,
  hl = "DiagnosticSignError",
})
sign({
  name = "DapBreakpointCondition",
  text = icons.dap.breakpoint.conditional,
  hl = "DiagnosticSignWarn",
})
sign({
  name = "DapLogPoint",
  text = icons.dap.breakpoint.log,
  hl = "DiagnosticSignInfo",
})
sign({
  name = "DapStopped",
  text = icons.dap.action.stop,
  hl = "DiagnosticSignInfo",
})
sign({
  name = "DapBreakpointRejected",
  text = icons.dap.breakpoint.unsupported,
  hl = "DiagnosticSignWarn",
})

vim.diagnostic.config({
  underline = true,
  -- virtual_lines = true,
  signs = true,
  severity_sort = true,
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
            return "NoiceMini"
          end,
        }
        return arr[k]()
      end,
    }),
    source = "always",
    border = {
      { "▀", "NoiceCmdlinePopupBorder" }, -- top left
      { "▀", "NoiceCmdlinePopupBorder" }, -- top
      { "▀", "NoiceCmdlinePopupBorder" }, -- top right
      { " ", "NoiceCmdlinePopupBorder" }, -- right
      { "▄", "NoiceCmdlinePopupBorder" }, -- bottom right
      { "▄", "NoiceCmdlinePopupBorder" }, -- bottom
      { "▄", "NoiceCmdlinePopupBorder" }, -- bottom left
      { " ", "NoiceCmdlinePopupBorder" }, -- left
    },
    focusable = false,
  },
  update_in_insert = true,
  -- virtual_text = {
  -- virt_text_pos = "right_align",
  -- prefix = "",
  -- format = function(diag)
  --   local severity = "Info"
  --   if diag.severity == 1 then
  --     severity = "Error"
  --   elseif diag.severity == 2 then
  --     severity = "Warn"
  --   elseif diag.severity == 3 then
  --     severity = "Hint"
  --   end
  --   return icons.diagnostics[severity] -- string.format("%s %s", icons.diagnostics[severity], diag.message)
  -- end,
  -- },
})
