return {
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
}
