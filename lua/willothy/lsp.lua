local utils = require("willothy.util")
local icons = require("willothy.icons")
local setmap = vim.keymap.set
local buf = vim.lsp.buf
local diagnostic = vim.diagnostic
local fn = vim.fn

local function mkcaps(extra)
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  if extra then
    -- snippets
    capabilities.textDocument.completion.completionItem.snippetSupport = true

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

    -- enable auto-import
    capabilities.textDocument.completion.completionItem.resolveSupport = {
      properties = { "documentation", "detail", "additionalTextEdits" },
    }

    capabilities.offsetEncoding = "utf-8"
  end

  capabilities.textDocument.semanticTokens = {
    augmentsSyntaxTokens = false,
  }

  return capabilities
end

local function lsp_maps(bufnr)
  local opts = { remap = false, silent = true, buffer = bufnr }

  local function map(m, lhs, rhs, desc)
    setmap(m, lhs, rhs, vim.tbl_deep_extend("keep", opts, { desc = desc }))
  end

  map("n", "gd", buf.definition, "Go to definition")
  map("n", "gD", buf.declaration, "Go to declaration")
  map("n", "gT", buf.type_definition, "Go to type definition")
  map("n", "gi", buf.implementation, "Go to implementation")
  map(
    "n",
    "K",
    function() require("rust-tools").hover_actions.hover_actions() end,
    "Hover docs"
  )
  map("n", "<leader>ws", buf.workspace_symbol, "Find workspace symbol")
  -- map("n", "<leader>fd", diagnostic.open_float, "Diagnostic float")
  map("n", "[d", diagnostic.goto_next, "Next diagnostic")
  map("n", "]d", diagnostic.goto_prev, "Previous diagnostic")
  map("n", "<leader>ca", function()
    -- require("actions-preview").code_actions()
    -- local win = vim.api.nvim_get_current_win()
    -- require("rust-tools").code_action_group.code_action_group()
    -- vim.api.nvim_set_current_win(win)
    require("hollywood").code_actions()
  end, "Code actions")
  map("n", "<leader>vh", buf.signature_help, "Signature help")

  local trouble = require("trouble").open
  map("n", "<leader>rr", utils.bind(trouble, "lsp_references"), "References")
  map("n", "<leader>vd", utils.bind(trouble, "lsp_definitions"), "Definitions")
  map(
    "n",
    "<leader>vd",
    utils.bind(trouble, "lsp_type_definitions"),
    "Type definitions"
  )
  map("n", "<leader>vq", utils.bind(trouble, "quickfix"), "Quickfix")
  map("n", "<leader>vl", utils.bind(trouble, "loclist"), "Loclist")

  local increname = function()
    vim.api.nvim_feedkeys(":IncRename " .. fn.expand("<cword>"), "n", false)
  end
  setmap("n", "<leader>rn", increname, { expr = true, desc = "Rename" })
  setmap("n", "<F2>", increname, { expr = true, desc = "Rename" })
end

local format
local function setup_format()
  format = require("lsp-format")
  format.setup({
    exclude = {
      clangd = true,
    },
  })
end

local function lsp_attach(client, bufnr)
  lsp_maps(bufnr)
  if not format then setup_format() end

  format.on_attach(client)

  if client.supports_method("textDocument/inlayHints") then
    vim.lsp.inlay_hint(bufnr, true)
  end
end

local lsp_settings = {
  ["bash-language-server"] = {
    bashIde = {
      includeAllWorkspaceSymbols = true,
    },
  },
  ["asm-lsp"] = {},
  clangd = {
    semanticHighlighting = true,
  },
  ["rust-analyzer"] = {
    diagnostics = {
      experimental = {
        enable = true,
      },
    },
    procMacro = {
      enable = true,
    },
    hover = {
      actions = {
        references = {
          enable = true,
        },
        run = {
          enable = true,
        },
        documentation = {
          enable = true,
        },
      },
      memoryLayout = {
        niches = true,
      },
    },
    imports = {
      granularity = {
        enforce = true,
        group = "crate",
      },
      group = {
        enable = true,
      },
      merge = {
        glob = true,
      },
    },
    inlayHints = {
      bindingModeHints = {
        enable = true,
      },
      closureCaptureHints = {
        enable = true,
      },
      closureReturnTypeHints = {
        enable = "always",
      },
      discriminantHints = {
        enable = "always",
      },
      expressionAdjustmentHints = {
        enable = "always",
        hideOutsideUnsafe = false,
      },
      lifetimeElisionHints = {
        enable = "always",
        useParameterNames = false,
      },
    },
    lens = {
      enable = true,
      references = {
        adt = {
          enable = true,
        },
        enumVariant = {
          enable = true,
        },
        method = {
          enable = true,
        },
        trait = {
          enable = true,
        },
      },
    },
  },
  lua_ls = {
    Lua = {
      workspace = {
        checkThirdParty = false,
      },
      completion = {
        workspaceWord = true,
        callSnippet = "Disable",
      },
      misc = {
        parameters = {
          "--log-level=info",
        },
      },
      diagnostics = {
        disable = { "incomplete-signature-doc" },
        enable = false,
        groupSeverity = {
          strong = "Warning",
          strict = "Warning",
        },
        groupFileStatus = {
          ["ambiguity"] = "Opened",
          ["await"] = "Opened",
          ["codestyle"] = "None",
          ["duplicate"] = "Opened",
          ["global"] = "Opened",
          ["luadoc"] = "Opened",
          ["redefined"] = "Opened",
          ["strict"] = "Opened",
          ["strong"] = "Opened",
          ["type-check"] = "Opened",
          ["unbalanced"] = "Opened",
          ["unused"] = "Opened",
        },
        unusedLocalExclude = { "_*" },
      },
      format = {
        enable = false,
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
          continuation_indent_size = "2",
        },
      },
      hint = {
        enable = true,
        setType = true,
        arrayIndex = "Enable",
        await = true,
        paramName = "All",
        paramType = true,
        semicolon = "SameLine",
      },
    },
  },
}

local function setup_null()
  local null_ls = require("null-ls")
  local builtins = null_ls.builtins

  null_ls.setup({
    sources = {
      builtins.formatting.stylua,
      builtins.diagnostics.selene,
      builtins.formatting.prettier,
      builtins.diagnostics.todo_comments,
      builtins.formatting.asmfmt,
      builtins.formatting.beautysh,
      -- builtins.formatting.pyink,
      -- builtins.formatting.markdownlint,
      builtins.formatting.taplo,
      -- builtins.diagnostics.commitlint,
      builtins.diagnostics.markdownlint,
      -- builtins.diagnostics.semgrep,
      -- builtins.diagnostics.shellcheck,
      builtins.diagnostics.zsh,
      -- builtins.code_actions.cspell,
      builtins.code_actions.gitrebase,
      builtins.hover.dictionary,
      builtins.hover.printenv,
    },
    on_attach = lsp_attach,
    should_attach = function(bufnr)
      if not vim.bo[bufnr].buflisted then return false end
      if vim.bo[bufnr].buftype ~= "" then return false end
      return true
    end,
  })
end

local function setup_ufo()
  local handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = ("  %d "):format(endLnum - lnum)
    local sufWidth = fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
      local chunkText = chunk[1]
      local chunkWidth = fn.strdisplaywidth(chunkText)
      if targetWidth > curWidth + chunkWidth then
        table.insert(newVirtText, chunk)
      else
        chunkText = truncate(chunkText, targetWidth - curWidth)
        local hlGroup = chunk[2]
        table.insert(newVirtText, { chunkText, hlGroup })
        chunkWidth = fn.strdisplaywidth(chunkText)
        -- str width returned from truncate() may less than 2nd argument, need padding
        if curWidth + chunkWidth < targetWidth then
          suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
        end
        break
      end
      curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, { suffix, "MoreMsg" })
    return newVirtText
  end

  -- global handler
  -- `handler` is the 2nd parameter of `setFoldVirtTextHandler`,
  -- check out `./lua/ufo.lua` and search `setFoldVirtTextHandler` for detail.
  local ufo = require("ufo")
  ufo.setup({
    fold_virt_text_handler = handler,
  })
  vim.schedule(function()
    local tab = vim.api.nvim_get_current_tabpage()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local bufnr = vim.api.nvim_win_get_buf(win)
      ufo.attach(bufnr)
    end
  end)
end

local function setup_rust()
  require("rust-tools").setup({
    tools = {
      inlay_hints = {
        auto = false,
      },
    },
    server = {
      on_attach = lsp_attach,
      settings = lsp_settings["rust-analyzer"],
    },
  })
  vim.cmd.LspStart("rust_analyzer")
end

local function lsp_setup()
  require("mason").setup()

  local lspconfig = require("lspconfig")
  local capabilities = mkcaps(true)

  require("mason-lspconfig").setup({
    handlers = {
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
          on_attach = lsp_attach,
          settings = lsp_settings[server_name],
        })
      end,
    },
  })

  setup_format()
  setup_ufo()

  local sign = function(opts)
    vim.fn.sign_define(opts.name, {
      texthl = opts.hl or opts.name,
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

  diagnostic.config({
    virtual_text = {
      prefix = "",
      format = function(diag)
        local severity = "Info"
        if diag.severity == 1 then
          severity = "Error"
        elseif diag.severity == 2 then
          severity = "Warn"
        elseif diag.severity == 3 then
          severity = "Hint"
        end
        return string.format("%s %s", icons.diagnostics[severity], diag.message)
      end,
    },
    signs = true,
    update_in_insert = true,
    underline = false,
    severity_sort = true,
    float = {
      source = "always",
      border = "rounded",
      focusable = false,
    },
  })
end

local filetypes = {
  asm = function()
    local lspconfig = require("lspconfig")
    lspconfig.asm_lsp.setup({
      settings = lsp_settings["asm-lsp"],
      attach = lsp_attach,
      capabilities = mkcaps(false),
      root_dir = lspconfig.util.root_pattern("Makefile", ".git", "*.asm"),
    })
  end,
  lua = function()
    require("lspconfig").lua_ls.setup({
      settings = lsp_settings["lua_ls"],
      attach = lsp_attach,
    })
  end,
  markdown = function()
    require("lspconfig").marksman.setup({
      settings = {},
      attach = lsp_attach,
      filetypes = { "markdown" },
    })
  end,
  toml = function()
    require("lspconfig").taplo.setup({
      settings = {},
      attach = lsp_attach,
      filetypes = { "toml" },
    })
  end,
  zsh = function()
    require("lspconfig").bashls.setup({
      settings = {},
      capabilities = mkcaps(false),
      attach = lsp_attach,
      filetypes = { "zsh", "sh", "bash" },
    })
  end,
}

for ft, init in pairs(filetypes) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = ft,
    once = true,
    callback = init,
  })
end

return {
  mkcaps = mkcaps,
  lsp_attach = lsp_attach,
  lsp_setup = lsp_setup,
  setup_rust = setup_rust,
  setup_null = setup_null,
  lsp_settings = lsp_settings,
}
