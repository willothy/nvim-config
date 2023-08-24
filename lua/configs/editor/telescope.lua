local function get_filename(path)
  local start, _ = path:find("[%w%s!-={-|]+[_%.].+")
  return path:sub(start, #path)
end

local side_by_side_min = 110

local function add_to_harpoon(prompt_bufnr)
  local fb_utils = require("telescope._extensions.file_browser.utils")
  local files = fb_utils.get_selected_files(prompt_bufnr) -- get selected files
  if #files == 0 then
    print("No files selected")
    return
  end
  local mark = require("harpoon.mark")
  for _, file in ipairs(files) do
    mark.toggle_file(file.filename)
  end
  if #files == 1 then
    local path = files[0] ~= nil and files[0].filename
      or files[1] ~= nil and files[1].filename
      or nil
    local message = path ~= nil and get_filename(path) or "1 file"
    print("Added " .. message .. " to harpoon")
  elseif #files > 1 then
    print("Added " .. #files .. " files to harpoon")
  end
end

local function create_and_add_to_harpoon(prompt_bufnr)
  local telescope = require("telescope")
  local fb_actions = telescope.extensions.file_browser.actions
  local path = fb_actions.create(prompt_bufnr)
  if path ~= nil then
    require("harpoon.mark").toggle_file(path)
    print("Added " .. get_filename(path) .. " to harpoon")
  end
end

---@class Theme
local Theme = {}
Theme.__index = Theme

---@return Theme
function Theme:with(opts)
  local theme = vim.tbl_extend("force", self, opts)
  return setmetatable(theme, Theme)
end

local my_theme = Theme:with({
  layout_strategy = "flex",
  borderchars = {
    -- preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    -- prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    -- results = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    preview = { " ", " ", " ", " ", " ", " ", " ", " " },
    prompt = { " ", " ", " ", " ", " ", " ", " ", " " },
    results = { " ", " ", " ", " ", " ", " ", " ", " " },
  },
})

local t = require("telescope")

t.setup({
  pickers = {},
  defaults = my_theme:with({
    history = {
      path = vim.fn.stdpath("data") .. "/databases/telescope_history.sqlite3",
      limit = 200,
    },
  }),
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_cursor({}),
    },
    file_browser = {
      theme = "ivy",
      mappings = {
        ["i"] = {
          ["<C-a>"] = add_to_harpoon,
          ["<C-n>"] = create_and_add_to_harpoon,
        },
        ["n"] = {
          ["c"] = create_and_add_to_harpoon,
          ["<C-a>"] = add_to_harpoon,
        },
      },
      layout_config = {
        width = vim.o.columns,
      },
      preview_title = false,
      results_title = false,
      prompt_path = true,
      display_stat = { date = false, size = false },
      borderchars = {
        preview = { " ", " ", " ", " ", " ", " ", " ", " " },
        prompt = { " ", " ", " ", " ", " ", " ", " ", " " },
        results = { " ", " ", " ", " ", " ", " ", " ", " " },
      },
    },
    undo = my_theme:with({
      use_delta = true,
      side_by_side = vim.o.columns > side_by_side_min,
      entry_format = "$STAT, $TIME",
      -- layout_strategy = "bottom_pane",
      sorting_strategy = "ascending",
      mappings = {
        i = {
          ["<cr>"] = require("telescope-undo.actions").yank_additions,
          ["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
          ["<C-cr>"] = require("telescope-undo.actions").restore,
        },
      },
      results_title = "Undo History",
      prompt_title = "Search",
      preview_title = "Edit Diff",
    }),
    macros = my_theme:with({
      theme = "dropdown",
      results_title = "Macros",
      prompt_title = "Find Macros",
    }),
    heading = {
      treesitter = true,
    },
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
    bookmarks = {
      selected_browser = "brave",
      url_open_command = "xdg-open",
    },
    frecency = my_theme:with({
      ignore_patterns = {
        "*.git/*",
        "*/tmp/*",
        "/home/willothy/.dotfiles/*",
      },
      show_scores = false,
      -- filepath_formatter = function()
      --   return "e"
      -- end,
      workspaces = {
        ["dotfiles"] = "/home/willothy/.config/",
        ["projects"] = "/home/willothy/projects/",
      },
      prompt_title = "Find Files",
      preview_title = "Preview",
      results_title = "Files",
    }),
  },
})

local extensions = {
  "menufacture",
  "fzf",
  "ui-select",
  "smart_history",
  "file_browser",
  -- "fzf_writer", -- currently broken
  "projects",
  "noice",
  "macros",
  "scope",
  "yank_history",
  "undo",
  "heading",
  "attempt",
  "bookmarks",
  "frecency",
}

vim.iter(extensions):each(t.load_extension)
