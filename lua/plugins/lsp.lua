return {
  -- DEVELOPMENT & TESTING --
  {
    "ThePrimeagen/refactoring.nvim",
    config = true,
    cmd = "Refactor",
  },
  -- {
  --   "folke/neodev.nvim",
  --   config = true,
  -- },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    -- commit = "cea5d0fb556cdc35122d9cae772e7e0ed65b4505",

    -- event="LspAttach",
    config = function()
      local lazydev = require("lazydev")
      -- require("lazydev.config").lua_root = false

      lazydev.setup({
        integrations = {
          cmp = false,
        },
        library = {
          "luvit-meta/library",
        },
      })
    end,
  },
  {
    "Bilal2453/luvit-meta", -- type defs for vim.uv
  },
  {
    "nvim-neotest/neotest",
    -- branch = "feat/use-external-nio",
    config = function()
      require("configs.editor.neotest")
    end,
    dependencies = {
      "rouge8/neotest-rust",
      "nvim-neotest/neotest-plenary",
    },
    cmd = "Neotest",
  },
  -- LSP UI --
  {
    "j-hui/fidget.nvim",
    config = function()
      require("configs.lsp.fidget")
    end,
    event = "LspAttach",
  },
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("configs.lsp.increname")
    end,
    cmd = "IncRename",
  },
  -- LANGUAGE SERVERS & RELATED TOOLS --
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = true,
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
  },
  {
    "neovim/nvim-lspconfig",
    -- commit = "8ab8f4cf48425dcb4845a61d3caa2d2a7e3d9df7",
    config = function()
      require("configs.lsp.lspconfig")
    end,
    -- config = true,
    event = "VeryLazy",
  },
  {
    "willothy/durable.nvim",
    dir = "~/projects/lua/durable.nvim/",
    event = "VeryLazy",
    config = function()
      require("durable").setup()
    end,
  },
  -- {
  --   "kevinhwang91/nvim-ufo",
  --   dependencies = {
  --     "kevinhwang91/promise-async",
  --   },
  --   event = "VeryLazy",
  --   config = true,
  -- },
  {
    "sourcegraph/sg.nvim",
    config = function()
      require("configs.lsp.sourcegraph")
    end,
    cmd = {
      "CodyTask",
      "CodyAsk",
      "CodyChat",
      "CodyToggle",
      "SourcegraphSearch",
      "SourcegraphLink",
    },
    event = "InsertEnter",
    -- build = "nvim -l build/init.lua",
  },
  -- {
  --   "garymjr/nvim-snippets",
  --   config = true,
  --   event = "InsertEnter",
  --   dependencies = {
  --     "rafamadriz/friendly-snippets",
  --   },
  -- },
  -- {
  --   "vxpm/ferris.nvim",
  --   config = function()
  --     require("ferris").setup()
  --
  --     local function cmd(name, module, opts)
  --       vim.api.nvim_create_user_command(name, function(...)
  --         require(module)(...)
  --       end, opts or {})
  --     end
  --
  --     cmd("FerrisExpandMacro", "ferris.methods.expand_macro")
  --     cmd("FerrisViewHIR", "ferris.methods.view_hir")
  --     cmd("FerrisViewMIR", "ferris.methods.view_mir")
  --     cmd("FerrisViewMemoryLayout", "ferris.methods.view_memory_layout")
  --     cmd("FerrisOpenCargoToml", "ferris.methods.open_cargo_toml")
  --     cmd("FerrisOpenParentModule", "ferris.methods.open_parent_module")
  --     cmd("FerrisOpenDocumentation", "ferris.methods.open_documentation")
  --     cmd("FerrisReloadWorkspace", "ferris.methods.reload_workspace")
  --   end,
  --   opts = {},
  --   cmd = {
  --     "FerrisViewHIR",
  --     "FerrisViewMIR",
  --     "FerrisViewMemoryLayout",
  --     -- "FerrisViewSyntaxTree",
  --     -- "FerrisViewItemTree",
  --     "FerrisOpenCargoToml",
  --     "FerrisOpenParentModule",
  --     "FerrisOpenDocumentation",
  --     "FerrisReloadWorkspace",
  --     -- "FerrisExpandMacro",
  --     -- "FerrisJoinLines",
  --     -- "FerrisRebuildMacros"
  --   },
  -- },
  {
    "p00f/clangd_extensions.nvim",
    config = true,
    event = "LspAttach",
  },
  -- DIAGNOSTICS & FORMATTING --
  {
    "nvimtools/none-ls.nvim",
    config = function()
      require("configs.lsp.null-ls")
    end,
    event = "VeryLazy",
  },
  {
    "stevearc/conform.nvim",
    config = function()
      require("configs.lsp.conform")
    end,
    event = "BufWritePre",
  },
  {
    "mfussenegger/nvim-lint",
    config = function()
      require("configs.lsp.nvim-lint")
    end,
    event = "VeryLazy",
  },
  {
    "dgagn/diagflow.nvim",
    config = function()
      require("configs.lsp.diagflow")
    end,
    event = "DiagnosticChanged",
  },
  -- COMPLETION --
  -- {
  --   "hrsh7th/nvim-cmp",
  --   dependencies = {
  --     "hrsh7th/cmp-buffer",
  --     "hrsh7th/cmp-path",
  --     "hrsh7th/cmp-cmdline",
  --     "hrsh7th/cmp-nvim-lsp",
  --     "dmitmel/cmp-cmdline-history",
  --     "rcarriga/cmp-dap",
  --     "zbirenbaum/copilot-cmp",
  --     -- {
  --     --   "jsongerber/nvim-px-to-rem",
  --     --   ft = { "css" },
  --     --   config = true,
  --     -- },
  --   },
  --   event = { "CmdlineEnter", "InsertEnter" },
  --   config = function()
  --     require("configs.editor.cmp")
  --   end,
  -- },
  {
    "Saghen/blink.cmp",
    -- enabled = false,
    -- How would I do a completion plugin?
    --
    -- - Fully async - users should never need to wait for the menu to open
    --   - Task-driven or callback-driven; don't mix the two
    -- - Sources push completions to an "epoch" (group of items from the same request context)
    -- - Things are added to the menu as they come, but discarded if they're from a previous epoch
    -- - Increment the epoch with every outgoing request + cancel inflight requests for prev. epoch
    -- - Maybe server-side fuzzy matching?
    -- - Menu components = fun(item: CompletionItem, ctx: Context): VirtTextChunk[]
    -- "willothy/blink.cmp",
    -- enabled = false,
    -- branch = "willothy/scrollbar",
    -- dir = "~/projects/lua/blink.cmp/",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    lazy = true,
    event = "InsertEnter",
    build = "cargo build --release",
    config = function()
      require("blink.cmp").setup({
        sources = {
          -- add lazydev to your completion providers
          completion = {
            enabled_providers = {
              "lsp",
              "path",
              -- "copilot",
              "snippets",
              "buffer",
              -- "lazydev",
            },
          },
          providers = {
            -- dont show LuaLS require statements when lazydev has items
            lsp = {
              -- fallback_for = { "lazydev" },
            },
            -- lazydev = {
            --   name = "LazyDev",
            --   module = "lazydev.integrations.blink",
            -- },
            --
            -- copilot = {
            --   name = "copilot",
            --   module = "blink.copilot",
            --   enabled = true,
            --   kind = "Copilot",
            --   max_items = 2,
            --
            --   score_offset = 1,
            -- },
          },
        },
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
        keymap = {
          -- preset = "super-tab",
          ["<C-space>"] = {
            "show",
            "show_documentation",
            "hide_documentation",
          },
          ["<C-e>"] = { "hide", "fallback" },

          ["<Tab>"] = {
            function(cmp)
              if cmp.is_in_snippet() then
                return cmp.accept()
              else
                return cmp.select_and_accept()
              end
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
        highlight = {
          use_nvim_cmp_as_default = true,
        },
        nerd_font_variant = "normal",
        trigger = {
          signature_help = {
            enabled = true,
          },
        },
        kind_icons = {
          Copilot = "",
        },

        windows = {
          autocomplete = {
            draw = {
              padding = 1,
              gap = 1,
              columns = {
                { "kind_icon" },
                { "label", "label_description", gap = 1 },
                { "kind" },
              },
              components = {
                kind_icon = {
                  ellipsis = false,
                  text = function(ctx)
                    return ctx.kind_icon .. " "
                  end,
                  highlight = function(ctx)
                    return "BlinkCmpKind" .. ctx.kind
                  end,
                },

                kind = {
                  ellipsis = false,
                  text = function(ctx)
                    return ctx.kind .. " "
                  end,
                  highlight = function(ctx)
                    return "BlinkCmpKind" .. ctx.kind
                  end,
                },

                label = {
                  width = { fill = true, max = 60 },
                  text = function(ctx)
                    return ctx.label .. (ctx.label_detail or "")
                  end,
                  highlight = function(ctx)
                    -- label and label details
                    local highlights = {
                      {
                        0,
                        #ctx.label,
                        group = ctx.deprecated and "BlinkCmpLabelDeprecated"
                          or "BlinkCmpLabel",
                      },
                    }
                    if ctx.label_detail then
                      table.insert(highlights, {
                        #ctx.label + 1,
                        #ctx.label + #ctx.label_detail,
                        group = "BlinkCmpLabelDetail",
                      })
                    end

                    -- characters matched on the label by the fuzzy matcher
                    if ctx.label_matched_indices ~= nil then
                      for _, idx in ipairs(ctx.label_matched_indices) do
                        table.insert(
                          highlights,
                          { idx, idx + 1, group = "BlinkCmpLabelMatch" }
                        )
                      end
                    end

                    return highlights
                  end,
                },

                label_description = {
                  width = { max = 30 },
                  text = function(ctx)
                    return ctx.label_description or ""
                  end,
                  highlight = "BlinkCmpLabelDescription",
                },
              },
            },
            -- draw = function(ctx)
            --   local hl = require("blink.cmp.utils").try_get_tailwind_hl(ctx)
            --     or ("BlinkCmpKind" .. ctx.kind)
            --
            --   return {
            --     " ",
            --     {
            --       ctx.kind_icon,
            --       hl_group = hl,
            --     },
            --     " ",
            --     {
            --       ctx.label,
            --       ctx.kind == "Snippet" and "~" or nil,
            --       (ctx.item.labelDetails and ctx.item.labelDetails.detail)
            --           and ctx.item.labelDetails.detail
            --         or "",
            --       hl_group = ctx.deprecated and "BlinkCmpLabelDeprecated"
            --         or "BlinkCmpLabel",
            --       max_width = 50,
            --       fill = true,
            --     },
            --     " ",
            --     {
            --       ctx.kind,
            --       hl_group = hl,
            --     },
            --     " ",
            --   }
            -- end,
          },
          documentation = {
            auto_show = true,
          },
          ghost_text = {
            enabled = true,
          },
        },
      })

      local kinds = require("blink.cmp.types").CompletionItemKind
      local k = #kinds + 1
      kinds[k] = "Copilot"
      kinds["Copilot"] = k
    end,
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      require("configs.editor.autopairs")
    end,
    event = "InsertEnter",
  },
  {
    "windwp/nvim-ts-autotag",
    config = true,
    event = "InsertEnter",
  },
  -- AI
  -- {
  --   "yetone/avante.nvim",
  --   event = "InsertEnter",
  --   build = ":AvanteBuild",
  --   config = function()
  --     require("1password").read(
  --       "op://Personal/Anthropic API Key/credential",
  --       vim.schedule_wrap(function(res)
  --         vim.env["ANTHROPIC_API_KEY"] = vim.trim(res)
  --         require("avante").setup({
  --           provider = "claude",
  --           claude = {
  --             endpoint = "https://api.anthropic.com",
  --             model = "claude-3-5-sonnet-20240620",
  --             temperature = 0,
  --             max_tokens = 4096,
  --           },
  --         })
  --       end)
  --     )
  --   end,
  --   dependencies = {
  --     "stevearc/dressing.nvim",
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --     --- The below dependencies are optional,
  --     "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
  --     "zbirenbaum/copilot.lua", -- for providers='copilot'
  --     {
  --       -- support for image pasting
  --       "HakonHarnes/img-clip.nvim",
  --       event = "VeryLazy",
  --       opts = {
  --         -- recommended settings
  --         default = {
  --           embed_image_as_base64 = false,
  --           prompt_for_file_name = false,
  --           drag_and_drop = {
  --             insert_mode = true,
  --           },
  --           -- required for Windows users
  --           use_absolute_path = true,
  --         },
  --       },
  --     },
  --     {
  --       -- Make sure to setup it properly if you have lazy=true
  --       "MeanderingProgrammer/render-markdown.nvim",
  --       opts = {
  --         file_types = { "markdown", "Avante" },
  --       },
  --       ft = { "markdown", "Avante" },
  --     },
  --   },
  -- },
  {
    "zbirenbaum/copilot.lua",
    config = function()
      require("configs.editor.copilot")
    end,
  },
  -- {
  --   "supermaven-inc/supermaven-nvim",
  --   event = "InsertEnter",
  --   opts = {
  --     log_level = "off",
  --     disable_keymaps = true,
  --     disable_inline_completion = true,
  --   },
  -- },
  -- {
  --   "lsportal/lsportal.nvim",
  --   config = true,
  --   dir = "~/work/foss/lsportal/lsportal.nvim/",
  -- },
  {
    "kylechui/nvim-surround",
    config = true,
    event = "InsertEnter",
  },
  -- DEBUGGING --
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      require("configs.debugging.dap")
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("configs.debugging.dap-ui")
    end,
  },
  -- Individual debugger plugins
  "jbyuki/one-small-step-for-vimkind",
}
