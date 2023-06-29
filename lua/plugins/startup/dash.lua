return {
  {
    "startup-nvim/startup.nvim",
    enabled = false,
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "ahmedkhalf/project.nvim",
    },
    config = function()
      local startup = require("startup")

      local project_layout = function()
        local layout =
          require("project_nvim.utils.history").get_recent_projects()
        local keys = {
          "w",
          "a",
          "s",
          "d",
          "f",
        }
        local out = {}
        vim.print(layout)
        for i, val in ipairs(layout) do
          local text = vim.fn.fnamemodify(val, ":~:.")
          table.insert(out, {
            "bruh",
            "a",
            -- string.format(
            --   'lua require"resession".load("%s", { dir = "dirsession" })',
            --   val
            -- ),
            -- keys[i],
            "z",
          })
        end
        vim.print(out)
        return out
      end

      local Section = {
        type = "text",
        oldfiles_directory = false,
        align = "center",
        fold_section = false,
        title = "Title",
        margin = 0.25,
        content = {},
        highlight = "Comment",
        default_color = "",
        oldfiles_amount = 0,
      }

      setmetatable(Section, {
        __call = function(self, init)
          return setmetatable(init, { __index = self })
        end,
      })

      startup.setup({
        header = Section({
          type = "text",
          -- align = "center",
          content = require("startup.headers").hydra_header,
          highlight = "DashboardHeader",
        }),
        buttons = Section({
          type = "mapping",
          -- align = "center",
          content = {
            -- { "  New file", 'call feedkeys("<leader>fn")', "f" },
            -- { "  Open last session", 'call feedkeys("<leader>pl")', "l" }, -- session load
            -- { "  Open current session", 'call feedkeys("<leader>pc")', "s" },
            { "  Find file", 'call feedkeys("<leader>ff")', "q" }, -- fuzzy find
            { "  Projects", 'call feedkeys("<leader>pf")', "p" }, -- open projects folder
            {
              "  Recently opened files",
              "lua require('telescope.builtin').oldfiles()",
              "r",
            },
            -- { "  Update plugins", "Lazy sync", "u" },
            { "  Edit neovim config", 'call feedkeys("<leader>nv")', "c" },
          },
          title = "Buttons",
        }),
        projects = Section({
          type = "mapping",
          content = vim.schedule_wrap(project_layout)(),
          title = "Projects",
        }),
        -- oldfiles = Section({
        --   type = "oldfiles",
        --   oldfiles_directory = true,
        --   oldfiles_amount = 2,
        -- }),
        -- sessions = Section({
        -- 	type = "mapping",
        -- 	align = "center",
        -- 	content = get_layout(),
        -- }),
        options = {
          mapping_keys = true, -- display mapping (e.g. <leader>ff)

          -- if < 0 fraction of screen width
          -- if > 0 numbers of column
          -- cursor_column = 0.5,

          empty_lines_between_mappings = false, -- add an empty line between mapping/commands
          disable_statuslines = false, -- disable status-, buffer- and tablines
          paddings = { 5, 3, 2, 1 }, -- amount of empty lines before each section (must be equal to amount of sections)
        },
        mappings = {
          execute_command = "<CR>",
          open_file = "o",
          open_file_split = "<c-o>",
          open_section = "<TAB>",
          open_help = "?",
        },
        colors = {
          background = "#1f2227",
          folded_section = "#56b6c2",
        },
        parts = {
          "header",
          "buttons",
          "projects",
          -- "oldfiles",
          -- "sessions",
        },
      })
    end,
  },
}
