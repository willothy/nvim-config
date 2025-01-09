vim.cmd("hi link BlinkCmpGhostText Comment")

require("configs.editor.crates")

require("blink.cmp").setup({
  keymap = {
    ["<C-h>"] = {
      "show",
      "show_documentation",
      "hide_documentation",
    },
    ["<C-space>"] = {
      "show",
      "show_documentation",
      "hide_documentation",
    },
    ["<C-e>"] = { "hide", "fallback" },

    ["<Tab>"] = {
      function(cmp)
        if cmp.snippet_active() then
          return cmp.accept()
        end
        return cmp.select_and_accept()
      end,
      "snippet_forward",
      "fallback",
    },
    ["<S-Tab>"] = { "snippet_backward", "fallback" },

    ["<Up>"] = { "select_prev", "fallback" },
    ["<Down>"] = { "select_next", "fallback" },
    ["<C-p>"] = { "select_prev", "fallback" },
    ["<C-n>"] = { "select_next", "fallback" },

    ["<C-u>"] = { "scroll_documentation_up", "fallback" },
    ["<C-d>"] = { "scroll_documentation_down", "fallback" },
  },
  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = "normal",
    kind_icons = willothy.ui.icons.kinds,
  },
  sources = {
    default = {
      "lsp",
      "path",
      "copilot",
      "snippets",
      "buffer",
    },
    per_filetype = {
      toml = {
        "crates",
        "lsp",
        "path",
        "copilot",
        "snippets",
        "buffer",
      },
      lua = {
        "lazydev",
        "lsp",
        "path",
        "copilot",
        "snippets",
        "buffer",
      },
    },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
        fallbacks = { "lsp" },
      },
      copilot = {
        name = "copilot",
        module = "blink-cmp-copilot",
        score_offset = 100,
        async = true,
      },
      crates = {
        name = "crates",
        module = "blink.compat.source",
        score_offset = 100,
        -- async = true,
      },
    },
  },
  completion = {
    -- trigger = {},
    -- list = {},
    -- accept = {},

    menu = {
      draw = {
        treesitter = { "lsp", "copilot" },
        padding = 1,
        gap = 1,
        columns = {
          { "kind_icon" },
          { "label", gap = 1 },
          { "kind" },
        },
        components = {
          kind_icon = {
            ellipsis = false,
            text = function(ctx)
              if ctx.item.source_name == "copilot" then
                return willothy.ui.icons.kinds.Copilot
              end
              return ctx.kind_icon
            end,
            highlight = function(ctx)
              if ctx.item.source_name == "copilot" then
                return "BlinkCmpKindCopilot"
              end
              return "BlinkCmpKind" .. ctx.kind
            end,
          },

          kind = {
            ellipsis = false,
            text = function(ctx)
              if ctx.item.source_name == "copilot" then
                local name = ctx.item.source_name
                return name:sub(1, 1):upper() .. name:sub(2) .. " "
              end
              return ctx.kind .. " "
            end,
            highlight = function(ctx)
              if ctx.item.source_name == "copilot" then
                return "BlinkCmpKindCopilot"
              end
              return "BlinkCmpKind" .. ctx.kind
            end,
          },

          label = {
            width = { fill = true, max = 60 },
            text = function(ctx)
              return ctx.label .. (ctx.label_detail or "")
            end,
          },
        },
      },
    },

    documentation = {
      auto_show = true,
      auto_show_delay_ms = 50,
    },

    ghost_text = {
      enabled = true,
    },
  },
  signature = {
    enabled = false,
  },
})
