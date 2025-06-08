return {
  {
    "nvim-pack/nvim-spectre",
    config = true,
    cmd = "Spectre",
  },
  {
    "nvimtools/hydra.nvim",
    dependencies = {
      "jbyuki/venn.nvim",
    },
    config = function()
      local venn_hint_utf = [[
 Arrow^^^^^^  Select region with <C-v>^^^^^^
 ^ ^ _K_ ^ ^  _f_: Surround with box ^ ^ ^ ^
 _H_ ^ ^ _L_  _<C-h>_: ◄, _<C-j>_: ▼
 ^ ^ _J_ ^ ^  _<C-k>_: ▲, _<C-l>_: ► _<C-c>_
]]

      local Hydra = require("hydra")

      -- :setlocal ve=all
      -- :setlocal ve=none
      local diagram_hydra = Hydra({
        name = "Draw Utf-8 Venn Diagram",
        hint = venn_hint_utf,
        config = {
          color = "pink",
          invoke_on_body = true,
          on_enter = function()
            vim.wo.virtualedit = "all"
          end,
        },
        mode = "n",
        body = "<leader>ve",
        heads = {
          { "<C-h>", "xi<C-v>u25c4<Esc>" }, -- mode = 'v' somehow breaks
          { "<C-j>", "xi<C-v>u25bc<Esc>" },
          { "<C-k>", "xi<C-v>u25b2<Esc>" },
          { "<C-l>", "xi<C-v>u25ba<Esc>" },
          { "H", "<C-v>h:VBox<CR>" },
          { "J", "<C-v>j:VBox<CR>" },
          { "K", "<C-v>k:VBox<CR>" },
          { "L", "<C-v>l:VBox<CR>" },
          { "f", ":VBox<CR>", { mode = "v" } },
          { "<C-c>", nil, { exit = true } },
        },
      })

      vim.api.nvim_create_user_command("Diagram", function()
        diagram_hydra:activate()
      end, {
        nargs = 0,
      })
    end,
    cmd = "Diagram",
  },
  -- COMMANDS --
  {
    "smjonas/live-command.nvim",
    config = true,
  },
  -- EDITING --
  {
    "numToStr/Comment.nvim",
    dependencies = {
      {
        "folke/ts-comments.nvim",
        config = true,
      },
    },
    opts = {
      pre_hook = function(ctx)
        -- if ctx.range.srow == ctx.range.erow then
        --   -- line
        -- else
        --   -- range
        -- end

        return require("ts-comments.comments").get(vim.bo.ft)
          or vim.bo.commentstring
      end,
      toggler = { -- Normal Mode
        line = "gcc",
        block = "gcb",
      },
      opleader = { -- Visual mode
        block = "gC",
        line = "gc",
      },
      ---@diagnostic disable-next-line: missing-fields
      extra = {
        eol = "gc$",
      },
    },
    event = "VeryLazy",
  },
  {
    "gbprod/substitute.nvim",
    opts = {
      yank_substituted_text = true,
    },
    event = "VeryLazy",
  },
  -- TREESITTER --
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    build = ":TSUpdate",
    -- commit = "9e1cda4e71a763ba1f1ac099498c7ce40edc6dd2",
    dependencies = {
      -- "nvim-treesitter/nvim-treesitter-textobjects",
      -- "IndianBoy42/tree-sitter-just",
      "chrisgrieser/nvim-various-textobjs",
    },
    config = function()
      require("willothy.treesitter")
    end,
  },
  {
    "jmbuhr/otter.nvim",
    ft = "markdown",
    config = function()
      require("configs.editor.otter")
    end,
  },
  {
    "folke/todo-comments.nvim",
    config = true,
    event = "VeryLazy",
  },
  -- DEFAULT FEATURE EXTENSIONS --
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          for k, v in pairs({
            print = function(...)
              Snacks.debug.inspect(...)
              return ...
            end,
          }) do
            vim[k] = v
          end

          local Snacks = Snacks

          Snacks.toggle
            .option("spell", { name = "Spelling" })
            :map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle
            .option("relativenumber", { name = "Relative Number" })
            :map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.inlay_hints():map("<leader>uh")
          Snacks.toggle.indent():map("<leader>ui")
          Snacks.toggle.dim():map("<leader>uD")
          Snacks.toggle.zoom():map("<leader>uz")
          Snacks.toggle.scroll():map("<leader>uS")
          Snacks.toggle.profiler():map("<leader>uP")
          Snacks.toggle.profiler_highlights():map("<leader>up")
        end,
      })

      ---@param self snacks.win
      local function add_borders(self)
        local win = assert(self.win)

        local macro = vim.api.nvim_get_hl(0, {
          name = "Macro",
          link = false,
          create = false,
        })

        local border = vim.api.nvim_get_hl(0, {
          name = "FloatBorder",
          link = false,
          create = false,
        })

        vim.api.nvim_set_hl(0, "SnacksInputBorder", {
          fg = macro.fg,
          bg = border.bg,
        })

        vim.wo[win].winhl = "FloatBorder:SnacksInputBorder"
      end

      local indent_disabled = {
        markdown = true,
        txt = true,
        text = true,
        help = true,
      }

      local Snacks = require("snacks")

      Snacks.setup({
        toggle = {},
        image = {},
        profiler = {},
        dashboard = {
          enabled = true,

          sections = {
            {
              align = "center",
              text = {
                { "Neovim", hl = "Identifier" },
                { " :: ", hl = "Comment" },
                { tostring(vim.version()), hl = "Identifier" },
              },
            },
            {
              align = "center",
              section = "startup",
            },
          },
        },
        layout = {},
        win = {},
        statuscolumn = {
          left = { "mark", "sign", "git" },
          right = { "fold" },
          folds = {
            open = true,
          },
        },
        picker = {
          prompt = "  ",
          sources = {
            files = {
              ---@diagnostic disable-next-line: missing-fields
              matcher = {
                frecency = true,
                sort_empty = true,
              },
            },
            projects = {
              confirm = function(...)
                return Snacks.picker.actions.load_session(...)
              end,
            },
          },
          ui_select = false,
          actions = require("trouble.sources.snacks").actions,
          layouts = {
            default = {
              layout = {
                box = "horizontal",
                width = 0.8,
                min_width = 120,
                height = 0.8,
                border = "none",
                {
                  box = "vertical",
                  border = "solid",
                  title = "{title} {live} {flags}",
                  {
                    win = "input",
                    height = 1,
                    border = "bottom",
                    on_win = add_borders,
                  },
                  { win = "list", border = "none" },
                },
                {
                  win = "preview",
                  title = "{preview}",
                  border = {
                    " ",
                    " ",
                    " ",
                    " ",
                    " ",
                    " ",
                    " ",
                    "│",
                  },
                  width = 0.5,
                },
              },
            },
            vertical = {
              layout = {
                backdrop = false,
                width = 0.5,
                min_width = 80,
                height = 0.8,
                min_height = 30,
                box = "vertical",
                border = "vpad",
                title = "{title} {live} {flags}",
                title_pos = "center",
                {
                  win = "input",
                  height = 1,
                  border = "bottom",
                  on_win = add_borders,
                },
                { win = "list", border = "none" },
                {
                  win = "preview",
                  title = "{preview}",
                  height = 0.4,
                  -- border = "vpad",
                },
              },
            },
          },
          win = {
            list = {
              border = "none",
            },
            preview = {
              border = "none",
            },
            input = {
              keys = {
                ["<C-t>"] = {
                  "trouble_open",
                  mode = { "n", "i" },
                },
              },
            },
          },
        },
        terminal = {
          bo = {},
        },
        notifier = {
          enabled = true,
          style = "compact",
          notification = {
            bo = {
              filetype = "markdown",
            },
          },
        },
        words = {},
        indent = {
          enabled = true,
          indent = {
            char = "▏",
            hl = "WinSeparator",
          },
          scope = {
            char = "▏",
            hl = "Function",
            only_current = true,
          },
          animate = {
            style = "out",
            fps = 120,
          },
          filter = function(buf)
            return vim.g.snacks_indent ~= false
              and vim.b[buf].snacks_indent ~= false
              and vim.bo[buf].buftype == ""
              and not indent_disabled[vim.bo[buf].filetype]
          end,
        },
        styles = {
          dashboard = {
            relative = "editor",
            layout = {
              layout = {
                border = "none",
              },
            },
          },
          notification = {
            relative = "editor",
            ft = "markdown",
            wo = {
              wrap = true,
            },
            bo = {
              filetype = "markdown",
            },
          },
          float = {
            relative = "editor",
            border = "solid",
          },
          input = {
            relative = "editor",
            border = "single",
          },
          minimal = {
            relative = "editor",
            border = "solid",
          },
          scratch = {
            relative = "editor",
            border = "single",
          },
          zen = {
            relative = "editor",
            border = "none",
          },
          zoom_indicator = {
            relative = "win",
            border = "none",
          },
        },
      })

      Snacks.picker.actions.load_session = function(picker)
        local item = picker:current()
        picker:close()
        if not item then
          return
        end
        local dir = item.file:gsub("/", "_")

        local resession = require("resession")

        local function hook_fn()
          resession.remove_hook("post_load", hook_fn)
        end

        resession.add_hook("post_load", hook_fn)

        resession.load(dir, {
          -- silence_errors = true,
          reset = true,
        })
      end
    end,
  },
  {
    "gbprod/yanky.nvim",
    dependencies = {
      "kkharji/sqlite.lua",
    },
    event = "VeryLazy",
    opts = {
      ring = { storage = "sqlite" },
    },
  },
  {
    "utilyre/sentiment.nvim",
    event = "VeryLazy",
    config = true,
  },
  -- FILE MANAGEMENT --
  {
    "stevearc/oil.nvim",
    config = function()
      require("configs.editor.oil")
    end,
    cmd = "Oil",
  },
  {
    "echasnovski/mini.visits",
    config = true,
    event = "VeryLazy",
  },
  -- SESSIONS / PROJECTS --
  {
    "stevearc/resession.nvim",
    dependencies = {
      {
        "tiagovla/scope.nvim",
        config = true,
        event = "VeryLazy",
      },
      "stevearc/oil.nvim",
    },
    config = function()
      require("willothy.sessions")
    end,
    event = "UiEnter",
  },
  -- {
  --   -- "ahmedkhalf/project.nvim",
  --   "DrKJeff16/project.nvim",
  --   name = "project_nvim",
  --   event = "VeryLazy",
  --   opts = {
  --     detection_methods = {
  --       "lsp",
  --       "pattern",
  --     },
  --     patterns = {
  --       ".git",
  --       "package.json",
  --       "Cargo.toml",
  --       "Makefile",
  --     },
  --     exclude_dirs = {
  --       "~/.local/",
  --       "~/.cargo/",
  --     },
  --     ignore_lsp = { "savior", "copilot" },
  --     silent_chdir = true,
  --     show_hidden = true,
  --     scope_chdir = "tab",
  --   },
  -- },
  {
    "willothy/savior.nvim",
    config = true,
    event = { "InsertEnter", "TextChanged" },
  },
  -- TERMINAL --
  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    -- dir = "~/projects/lua/toggleterm.nvim/",
    config = function()
      require("configs.terminal.toggleterm")
    end,
  },
  {
    "willothy/flatten.nvim",
    dir = "~/projects/lua/flatten.nvim/",
    lazy = false,
    priority = 1000,
    config = function()
      require("configs.terminal.flatten")
    end,
  },
  {
    "willothy/wezterm.nvim",
    -- dir = "~/projects/lua/wezterm.nvim/",
    config = function()
      require("configs.editor.wezterm")
    end,
    cmd = { "Wezterm" },
  },
  {
    "stevearc/overseer.nvim",
    config = function()
      require("willothy.tasks")
    end,
    event = { "UiEnter", "VeryLazy" },
  },
  -- NAVIGATION --
  {
    "folke/flash.nvim",
    config = function()
      require("configs.navigation.flash")
    end,
    keys = {
      { "f", desc = "flash" },
      { "F", desc = "flash" },
      { "t", desc = "flash" },
      { "T", desc = "flash" },
    },
  },
  {
    "chrisgrieser/nvim-spider",
    config = true,
  },
  {
    "abecodes/tabout.nvim",
  },
  -- GIT --
  {
    "lewis6991/gitsigns.nvim",
    -- enabled = false,
    config = function()
      require("configs.git.gitsigns")
    end,
    event = "VeryLazy",
  },
  {
    "sindrets/diffview.nvim",
    config = true,
    cmd = {
      "DiffviewOpen",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
  },
  {
    "akinsho/git-conflict.nvim",
    config = function()
      require("configs.git.git-conflict")
    end,
    event = "VeryLazy",
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    config = function()
      require("configs.git.neogit")
    end,
  },
  -- MISC --
  {
    "echasnovski/mini.trailspace",
    config = function()
      require("mini.trailspace").setup()
    end,
    event = { "VimEnter" },
  },
  {
    "chomosuke/term-edit.nvim",
    opts = {
      prompt_end = "-> ",
    },
    event = "TermEnter",
  },
  {
    "tris203/precognition.nvim",
    opts = {
      startVisible = false,
      showBlankVirtLine = false,
    },
    event = "VeryLazy",
  },
  {
    "johmsalas/text-case.nvim",
    opts = {
      default_keymappings_enabled = false,
    },
  },
}
