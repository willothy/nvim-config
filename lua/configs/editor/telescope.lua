local telescope = require("telescope")

local schedule_if_buf_valid = function(buf, fn)
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then
      fn()
    end
  end)
end

local mouse_click = function(prompt_bufnr)
  local action_state = require("telescope.actions.state")
  local actions = require("telescope.actions")
  local picker = action_state.get_current_picker(prompt_bufnr)

  local pos = vim.fn.getmousepos()
  if pos and pos.winid == picker.results_win then
    schedule_if_buf_valid(prompt_bufnr, function()
      picker:set_selection(pos.line - 1)
    end)
  elseif pos and pos.winid == picker.preview_win then
    schedule_if_buf_valid(prompt_bufnr, function()
      actions.select_default(prompt_bufnr)
    end)
  end
  return ""
end

local function mouse_move(prompt_bufnr)
  local action_state = require("telescope.actions.state")
  local picker = action_state.get_current_picker(prompt_bufnr)

  local mouse = vim.fn.getmousepos()
  if mouse and mouse.winid == picker.results_win then
    schedule_if_buf_valid(prompt_bufnr, function()
      picker:set_selection(mouse.line - 1)
    end)
    return ""
  else
    return "<MouseMove>"
  end
end

local trouble = require("trouble.sources.telescope")

telescope.setup({
  pickers = {},
  defaults = {
    -- initial_mode = "normal",
    history = {
      path = vim.fn.stdpath("data") .. "/databases/telescope_history.sqlite3",
      limit = 200,
    },
    create_layout = willothy.ui.telescope.flexible,
    find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
    dynamic_preview_title = true,
    -- get_status_text = function(self, opts)
    --   return ""
    -- end,
    mappings = {
      i = {
        ["<MouseMove>"] = {
          mouse_move,
          type = "action",
          opts = { expr = true },
        },
        ["<leftmouse>"] = {
          mouse_click,
          type = "action",
          opts = { expr = true },
        },
        ["<C-t>"] = trouble.open,
      },
      n = {
        ["<MouseMove>"] = {
          mouse_move,
          type = "action",
          opts = { expr = true },
        },
        ["<LeftMouse>"] = {
          mouse_click,
          type = "action",
          opts = { expr = true },
        },
        ["<C-t>"] = trouble.open,
      },
    },
  },
  extensions = {
    file_browser = {
      mappings = {
        ["i"] = {
          ["<C-t>"] = trouble.open,
        },
        ["n"] = {
          ["<C-t>"] = trouble.open,
        },
      },
      sorting_strategy = "ascending",
      prompt_path = true,
      create_layout = willothy.ui.telescope.bottom_pane,
      -- display_stat = false,
    },
    macros = {
      theme = "dropdown",
      results_title = "Macros",
      prompt_title = "Find Macros",
    },
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
    bookmarks = {
      selected_browser = "brave",
      url_open_command = "xdg-open",
    },
    frecency = {
      ignore_patterns = {
        "*.git/*",
        "*/tmp/*",
        "/home/willothy/.dotfiles/*",
      },
      use_sqlite = false,
      show_scores = false,
      show_unindexed = true,
      db_safe_mode = false,
      default_workspace = "CWD",
      workspaces = {
        -- ["nvim"] = "/home/willothy/.config/nvim/",
        ["dotfiles"] = "/home/willothy/.config",
        ["projects"] = "/home/willothy/projects",
        ["lua"] = "/home/willothy/projects/lua",
        ["rust"] = "/home/willothy/projects/rust",
        ["js"] = "/home/willothy/projects/js/",
        ["cxx"] = "/home/willothy/projects/cxx/",
      },
      prompt_title = "Find Files",
      preview_title = "Preview",
      results_title = "Files",
      temp__scrolling_limit = 100,
    },
  },
})

for _, ext in ipairs({
  "fzf",
  "frecency",
  -- "smart_history",
  -- "neoclip",
  -- "file_browser",
  -- "projects",
  -- "noice",
  -- "macros",
  -- "scope",
  -- "yank_history",
  -- "attempt",
  -- "bookmarks",
}) do
  telescope.load_extension(ext)
end
