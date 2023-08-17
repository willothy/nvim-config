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

local my_theme = require("telescope.themes").get_ivy({
  layout_strategy = "flex",
  prompt_title = "",
  prompt_prefix = "",
  preview_title = "",
  borderchars = {
    preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    results = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
  },
})
local t = require("telescope")

local function with(o, theme)
  return vim.tbl_deep_extend("keep", o, theme)
end

t.setup({
  pickers = {},
  defaults = {
    theme = my_theme,
  },
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
    },
    undo = with({
      use_delta = true,
      side_by_side = vim.o.columns > side_by_side_min,
      entry_format = "$STAT, $TIME",
      layout_strategy = "bottom_pane",
      sorting_strategy = "ascending",
      mappings = {
        i = {
          ["<cr>"] = require("telescope-undo.actions").yank_additions,
          ["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
          ["<C-cr>"] = require("telescope-undo.actions").restore,
        },
      },
    }, my_theme),
    macros = {
      theme = "ivy",
    },
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
    frecency = with({
      ignore_patterns = { "*.git/*", "*/tmp/*", "/home/willothy/.dotfiles/*" },
      show_scores = true,
      workspaces = {
        ["dotfiles"] = "/home/willothy/.config/",
        ["projects"] = "/home/willothy/projects/",
      },
    }, my_theme),
  },
})

local extensions = {
  "menufacture",
  "ui-select",
  "fzf",
  "file_browser",
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

vim.api.nvim_create_autocmd("BufWinLeave", {
  callback = function(ev)
    if vim.bo[ev.buf].filetype == "TelescopePrompt" then
      vim.cmd("silent! stopinsert!")
    end
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopePreviewerLoaded",
  callback = function()
    vim.wo.wrap = false
  end,
})
