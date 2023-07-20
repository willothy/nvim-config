return {
  {
    "folke/noice.nvim",
    cond = vim.g.started_by_firenvim == nil,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    event = "UiEnter",
    config = function()
      require("noice").setup({
        presets = {
          long_message_to_split = true,
          inc_rename = true,
        },
        smart_move = {
          enabled = true,
        },
        views = {
          cmdline_popup = {
            position = {
              row = "35%",
              col = "50%",
            },
            border = {
              style = "rounded",
              padding = { 0, 0 },
            },
            filter_options = {},
            win_options = {
              winhighlight = {
                Normal = "Normal",
                FloatBorder = "FloatBorder",
              },
              cursorline = false,
            },
            size = {
              width = "auto",
              height = "auto",
            },
          },
          hover = {
            border = {
              style = "rounded",
              padding = { 0, 0 },
            },
          },
          popupmenu = {
            relative = "editor",
            position = {
              row = "40%",
              col = "50%",
            },
            size = {
              width = 80,
              height = 10,
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
            win_options = {
              winhighlight = { Normal = "Normal", FloatBorder = "FloatBorder" },
            },
          },
        },
        lsp = {
          --override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
          progress = {
            enabled = true,
            view = "mini",
          },
          signature = {
            enabled = true,
            auto_open = {
              enabled = true,
              trigger = true,
              luasnip = true,
              throttle = 50,
            },
            opts = {},
          },
          hover = {
            enabled = true,
          },
        },
        cmdline = {
          view = "cmdline_popup",
          format = {
            search_down = {
              view = "cmdline",
            },
            search_up = {
              view = "cmdline",
            },
            python = {
              pattern = { "^:%s*pyt?h?o?n?%s+", "^:%s*py?t?h?o?n%s*=%s*" },
              icon = "󰌠",
              lang = "python",
            },
          },
        },
        popupmenu = {
          enabled = true,
          backend = "nui",
        },
        messages = {
          enabled = true, -- enables the Noice messages UI
          view = "notify", -- default view for messages
          view_error = "notify", -- view for errors
          view_warn = "notify", -- view for warnings
          view_history = "messages", -- view for :messages
          view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
        },
        -- notify = {
        --   enabled = true,
        --   view = "mini",
        -- },
        routes = {
          {
            filter = {
              any = {
                { find = "%d+L, %d+B written" },
                { find = "%d+ change[s]?; before #%d+" },
                { find = "%d+ change[s]?; after #%d+" },
              },
            },
            view = "mini",
            opts = {
              stop = true,
              skip = false,
            },
          },
        },
      })

      vim.notify_mini = function(msg, opts)
        local title = opts.title
        local level = opts.level or vim.log.levels.INFO
        require("noice.message.router").redirect(
          function()
            vim.notify(msg, level, {
              title = title,
            })
          end,
          {
            { filter = {}, view = "mini" },
          }
        )
      end

      vim.redirect = function(view, msg, title)
        require("noice.message.router").redirect(
          function()
            vim.notify(msg, vim.log.levels.INFO, {
              title = title or "Notify",
            })
          end,
          {
            { filter = {}, view = view },
          }
        )
      end
    end,
  },
  {
    "rcarriga/nvim-notify",
    event = "UiEnter",
    config = function()
      local notify = require("notify")

      local stages_util = require("notify.stages.util")
      local Dir = stages_util.DIRECTION

      local function anim(direction)
        return {
          function(state)
            local next_row = stages_util.available_slot(
              state.open_windows,
              state.message.height,
              direction
            )
            if not next_row then return nil end
            return {
              relative = "editor",
              anchor = "NE",
              width = 1,
              height = state.message.height,
              col = vim.opt.columns:get(),
              row = next_row,
              border = "rounded",
              style = "minimal",
            }
          end,
          function(state, win)
            return {
              width = { state.message.width },
              col = { vim.opt.columns:get() },
              row = {
                stages_util.slot_after_previous(
                  win,
                  state.open_windows,
                  direction
                ),
                frequency = 3,
                complete = function() return true end,
              },
            }
          end,
          function(state, win)
            return {
              col = { vim.opt.columns:get() },
              time = true,
              row = {
                stages_util.slot_after_previous(
                  win,
                  state.open_windows,
                  direction
                ),
                frequency = 3,
                complete = function() return true end,
              },
            }
          end,
          function(state, win)
            return {
              width = {
                1,
                frequency = 2.5,
                damping = 0.9,
                complete = function(cur_width) return cur_width < 3 end,
              },
              col = { vim.opt.columns:get() },
              row = {
                stages_util.slot_after_previous(
                  win,
                  state.open_windows,
                  direction
                ),
                frequency = 3,
                complete = function() return true end,
              },
            }
          end,
        }
      end

      notify.setup({
        fps = 60,
        render = "compact",
        timeout = 3000,
        stages = anim(Dir.TOP_DOWN),
        -- top_down = false,
        background_color = "none",
      })
    end,
  },
}
