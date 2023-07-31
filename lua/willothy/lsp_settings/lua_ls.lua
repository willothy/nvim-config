return {
  Lua = {
    workspace = {
      checkThirdParty = false,
    },
    completion = {
      callSnippet = "Disable",
    },
    misc = {},
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
      arrayIndex = "Disable",
      await = true,
      paramName = "All",
      paramType = true,
      semicolon = "SameLine",
    },
  },
}
