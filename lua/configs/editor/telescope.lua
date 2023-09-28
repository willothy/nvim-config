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

local open_win = function(enter, width, height, row, col, title, border)
  local Layout = require("telescope.pickers.layout")
  local bufnr = vim.api.nvim_create_buf(false, true)
  local winid = vim.api.nvim_open_win(bufnr, enter, {
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = border or "solid",
    title = title,
    title_pos = title and "center",
  })

  return Layout.Window({
    bufnr = bufnr,
    winid = winid,
  })
end

local close_win = function(window)
  if window then
    if vim.api.nvim_win_is_valid(window.winid) then
      vim.api.nvim_win_close(window.winid, true)
    end
    if vim.api.nvim_buf_is_valid(window.bufnr) then
      vim.api.nvim_buf_delete(window.bufnr, { force = true })
    end
  end
end

local update_win = function(window, opts)
  if window then
    if vim.api.nvim_win_is_valid(window.winid) then
      vim.api.nvim_win_set_config(
        window.winid,
        vim.tbl_deep_extend(
          "force",
          vim.api.nvim_win_get_config(window.winid),
          opts
        )
      )
    end
  end
end

local bottom_pane = function(picker)
  local Layout = require("telescope.pickers.layout")

  local function get_configs()
    local height = math.floor((vim.o.lines / 2) + 0.5) - 2

    local hide_preview = vim.o.columns < 80
    local preview_ratio = 3

    local function map_range(
      input_start,
      input_end,
      output_start,
      output_end,
      input
    )
      local input_length = input_end - input_start
      local output_length = output_end - output_start
      return (
        output_start + ((input - input_start) / input_length) * output_length
      )
    end

    preview_ratio =
      math.max(2, math.min(3, map_range(80, 150, 3, 2, vim.o.columns)))

    local preview_width = math.floor(vim.o.columns / preview_ratio) - 2
    local results_width = hide_preview and vim.o.columns
      or (math.floor(vim.o.columns - preview_width) - 3)

    local res = {}

    res.results = {
      width = results_width,
      height = height - 3,
      row = vim.o.lines - height,
      col = 0,
    }
    if not hide_preview then
      res.preview = {
        width = preview_width,
        height = height - 1,
        row = vim.o.lines - height - 2,
        col = results_width + 2,
      }
    end
    res.prompt = {
      width = results_width,
      height = 1,
      row = math.floor(vim.o.lines / 2),
      col = 0,
    }
    return res
  end

  local layout = {}

  layout.picker = picker

  function layout:mount()
    local c = get_configs()
    self.results = open_win(
      false,
      c.results.width,
      c.results.height,
      c.results.row,
      c.results.col,
      "Results"
    )
    self.preview = open_win(
      false,
      c.preview.width,
      c.preview.height,
      c.preview.row,
      c.preview.col,
      "Preview"
    )
    self.prompt = open_win(
      true,
      c.prompt.width,
      c.prompt.height,
      c.prompt.row,
      c.prompt.col,
      "Prompt"
    )
  end

  function layout:update()
    local c = get_configs()
    update_win(self.results, c.results)
    if self.preview and c.preview then
      update_win(self.preview, c.preview)
    elseif c.preview and not self.preview then
      self.preview = open_win(
        false,
        c.preview.width,
        c.preview.height,
        c.preview.row,
        c.preview.col,
        "Preview"
      )
    elseif not c.preview and self.preview then
      close_win(self.preview)
      self.preview = nil
    end
    update_win(self.prompt, c.prompt)
  end

  function layout:unmount()
    close_win(self.results)
    close_win(self.preview)
    close_win(self.prompt)
  end

  return Layout(layout)
end

local custom = function(picker)
  local Layout = require("telescope.pickers.layout")

  local function get_configs()
    local width = math.min(math.floor(vim.o.columns / 3) * 2, 120)
    local height = math.floor((vim.o.lines / 3) + 0.5) * 2

    local preview_ratio = 3
    local ease_linear = function(min, max, value)
      return min + (max - min) * value
    end

    preview_ratio = ease_linear(3, 2, (width - 80) / 40)

    if vim.o.columns > 120 then
      local row = math.floor((vim.o.lines / 2) - (height / 2))
      local col = math.floor((vim.o.columns / 2) - (width / 2))

      local preview_width = math.floor(width / preview_ratio) - 1
      local results_width = math.floor(width - preview_width)

      return {
        results = {
          width = results_width,
          height = height - 2,
          row = row,
          col = col,
        },
        preview = {
          width = preview_width,
          height = height,
          row = row,
          col = col + results_width + 1,
        },
        prompt = {
          width = results_width,
          height = 1,
          row = row + height - 1,
          col = col,
        },
      }
    else
      local row = math.floor((vim.o.lines / 2) - (height / 2))
      local col = math.floor((vim.o.columns / 2) - (width / 2))

      local hide_preview = false
      if vim.o.lines < 40 then
        hide_preview = true
      end

      local res = {}

      local results_height = (
        hide_preview and height or math.floor(height / 2)
      ) - 2
      res.results = {
        width = width,
        height = results_height,
        row = row + (hide_preview and 0 or math.floor(height / 2)),
        col = col,
      }
      res.prompt = {
        width = width,
        height = 1,
        row = row + height - 1,
        col = col,
      }
      if not hide_preview then
        res.preview = {
          width = width,
          height = math.floor(height / 2),
          row = row,
          col = col,
        }
      end
      return res
    end
  end

  local layout = {}

  layout.picker = picker

  function layout:mount()
    local c = get_configs()
    self.results = open_win(
      false,
      c.results.width,
      c.results.height,
      c.results.row,
      c.results.col,
      "Results"
    )
    if c.preview then
      self.preview = open_win(
        false,
        c.preview.width,
        c.preview.height,
        c.preview.row,
        c.preview.col,
        "Preview"
      )
    end
    self.prompt = open_win(
      true,
      c.prompt.width,
      c.prompt.height,
      c.prompt.row,
      c.prompt.col,
      nil,
      c.prompt.border
    )
  end

  function layout:update()
    local c = get_configs()
    update_win(self.results, c.results)
    if self.preview and c.preview then
      update_win(self.preview, c.preview)
    elseif c.preview and not self.preview then
      self.preview = open_win(
        false,
        c.preview.width,
        c.preview.height,
        c.preview.row,
        c.preview.col,
        "Preview"
      )
    elseif not c.preview and self.preview then
      close_win(self.preview)
      self.preview = nil
    end
    update_win(self.prompt, c.prompt)
  end

  function layout:unmount()
    close_win(self.results)
    close_win(self.preview)
    close_win(self.prompt)
  end

  return Layout(layout)
end

t.setup({
  pickers = {},
  defaults = my_theme:with({
    history = {
      path = vim.fn.stdpath("data") .. "/databases/telescope_history.sqlite3",
      limit = 200,
    },
    create_layout = custom,
  }),
  extensions = {
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
      create_layout = bottom_pane,
    },
    undo = {
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
      create_layout = custom,
    },
    macros = {
      theme = "dropdown",
      results_title = "Macros",
      prompt_title = "Find Macros",
      create_layout = custom,
    },
    heading = {
      treesitter = true,
      create_layout = custom,
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
      create_layout = custom,
    },
    frecency = my_theme:with({
      ignore_patterns = {
        "*.git/*",
        "*/tmp/*",
        "/home/willothy/.dotfiles/*",
      },
      show_scores = false,
      workspaces = {
        ["dotfiles"] = "/home/willothy/.config/",
        ["projects"] = "/home/willothy/projects/",
      },
      prompt_title = "Find Files",
      preview_title = "Preview",
      results_title = "Files",
      create_layout = custom,
    }),
  },
})

local extensions = {
  "menufacture",
  "fzf",
  "neoclip",
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
