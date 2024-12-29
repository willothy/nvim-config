local function make_capabilities()
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

  return require("blink.cmp").get_lsp_capabilities(capabilities, true)
end

return {
  make_capabilities = make_capabilities,
}
