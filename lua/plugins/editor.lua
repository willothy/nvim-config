return {
  {
    "nvim-pack/nvim-spectre",
    config = true,
    cmd = "Spectre",
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
    config = function()
      require("configs.editor.comment")
    end,
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
      require("configs.editor.treesitter")
      -- pcall(vim.treesitter.start)
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
        end,
      })

      local indent_disabled = {
        markdown = true,
        txt = true,
        text = true,
        help = true,
      }

      require("snacks").setup({
        toggle = {},
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
        statuscolumn = {
          left = { "mark", "sign", "git" },
          right = { "fold" },
          folds = {
            open = true,
          },
        },
        picker = {
          sources = {
            files = {
              ---@diagnostic disable-next-line: missing-fields
              matcher = {
                frecency = true,
                sort_empty = true,
              },
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
                border = "single",
                {
                  box = "vertical",
                  border = "solid",
                  title = "{title} {live} {flags}",
                  { win = "input", height = 1, border = "bottom" },
                  { win = "list", border = "none" },
                },
                {
                  win = "preview",
                  title = "{preview}",
                  border = "left",
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
                border = "single",
                title = "{title} {live} {flags}",
                title_pos = "center",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
                {
                  win = "preview",
                  title = "{preview}",
                  height = 0.4,
                  border = "top",
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
      require("configs.editor.overseer")
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
