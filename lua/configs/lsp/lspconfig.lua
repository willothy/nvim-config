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

-- capabilities = require("blink.cmp").get_lsp_capabilities(capabilities, true)

vim.lsp.config("*", {
  capabilities = capabilities,
})

require("mason").setup()
local lspconfig = require("lspconfig")

local neoconf = require("neoconf")
neoconf.setup({})

local function settings(server, default)
  return neoconf.get("lspconfig." .. server, default or {}, { lsp = true })
end

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

lspconfig.gleam.setup({
  capabilities = capabilities,
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
    lua_ls = function()
      -- vim.lsp.enable("lua_ls", true)
      require("lspconfig").lua_ls.setup({
        capabilities = capabilities,
        settings = settings("lua_ls"),
        root_dir = require("lspconfig.util").root_pattern(
          ".luarc.json",
          ".luarc.jsonc",
          ".luacheckrc",
          ".stylua.toml",
          "stylua.toml",
          "selene.toml",
          "selene.yml",
          ".git"
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
    -- bufls = function()
    --   lspconfig.bufls.setup({
    --     capabilities = capabilities,
    --     filetypes = { "proto" },
    --     settings = settings("bufls"),
    --     root_dir = require("lspconfig.util").root_pattern(".git"),
    --   })
    -- end,
    intelephense = function()
      lspconfig.intelephense.setup({
        settings = settings("intelephense"),
        capabilities = capabilities,
        root_dir = require("lspconfig.util").root_pattern(".git"),
      })
    end,
  },
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
