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
    mark.add_file(file.filename)
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
    require("harpoon.mark").add_file(path)
    print("Added " .. get_filename(path) .. " to harpoon")
  end
end

local t = require("telescope")
local undo = {
  use_delta = true,
  side_by_side = vim.o.columns > side_by_side_min,
  entry_format = "$STAT, $TIME",
  layout_strategy = "bottom_pane",
  sorting_strategy = "ascending",
  results_title = false,
  layout_config = {
    preview_width = vim.o.columns > side_by_side_min and 0.75 or 0.65,
    preview_cutoff = 1,
    height = 0.8,
    width = 0.9,
  },
  border = true,
  borderchars = {
    prompt = { "─", " ", " ", " ", "─", "─", " ", " " },
    results = { " " },
    preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
  },
  mappings = {
    i = {
      ["<cr>"] = require("telescope-undo.actions").yank_additions,
      ["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
      ["<C-cr>"] = require("telescope-undo.actions").restore,
    },
  },
}
t.setup({
  pickers = {
    find_files = {
      layout_config = {
        preview_cutoff = 1,
      },
      theme = "ivy",
    },
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_cursor({}),
    },
    file_browser = {
      theme = "ivy",
      hijack_netrw = true,
      mappings = {
        ["i"] = {
          ["<C-a>"] = add_to_harpoon,
          ["<C-n>"] = create_and_add_to_harpoon,
        },
        ["n"] = {
          ["c"] = create_and_add_to_harpoon,
          ["a"] = add_to_harpoon,
        },
      },
    },
    undo = undo,
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
    frecency = {
      ignore_patterns = { "*.git/*", "*/tmp/*", "/home/willothy/.dotfiles/*" },
      show_scores = true,
      workspaces = {
        ["dotfiles"] = "/home/willothy/.config/",
        ["projects"] = "/home/willothy/projects/",
      },
    },
  },
})

-- don't need any of these right away
local function defer(extension)
  vim.defer_fn(function()
    require("telescope").load_extension(extension)
  end, 1000)
end

defer("file_browser")
defer("menufacture")
defer("projects")
defer("noice")
defer("macros")
defer("scope")
defer("yank_history")
defer("undo")
defer("fzf")

defer("ui-select")
defer("heading")
defer("attempt")
defer("bookmarks")
defer("frecency")

vim.api.nvim_create_autocmd("BufWinLeave", {
  callback = function(ev)
    if vim.bo[ev.buf].filetype == "TelescopePrompt" then
      vim.cmd("silent! stopinsert!")
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  callback = function(_ev)
    local width = vim.api.nvim_get_option("columns")
    undo.side_by_side = width > side_by_side_min
    undo.layout_config.preview_width = vim.o.columns > side_by_side_min and 0.75
      or 0.65
    require("telescope._extensions.undo").setup(undo)
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopePreviewerLoaded",
  callback = function()
    vim.wo.wrap = false
  end,
})
