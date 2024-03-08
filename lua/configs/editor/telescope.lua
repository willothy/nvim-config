local telescope = require("telescope")

local schedule_if_buf_valid = function(buf, fn)
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then
      fn()
    end
  end)
end

---FIXME: I never use these mouse mappings. I should remove them.

local mouse_scroll_up = function(prompt_bufnr)
  local action_state = require("telescope.actions.state")
  local actions = require("telescope.actions")
  local picker = action_state.get_current_picker(prompt_bufnr)

  local mouse_win = vim.fn.getmousepos().winid
  if picker.results_win == mouse_win then
    local win_info = vim.api.nvim_win_call(mouse_win, vim.fn.winsaveview)
    if win_info.topline > 1 then
      schedule_if_buf_valid(prompt_bufnr, function()
        -- picker:set_selection(vim.fn.getmousepos().line - 1)
        actions.results_scrolling_up(prompt_bufnr)
      end)
    end
    return ""
  elseif mouse_win == picker.preview_win then
    schedule_if_buf_valid(prompt_bufnr, function()
      actions.preview_scrolling_up(prompt_bufnr)
    end)
    return ""
  else
    return "<ScrollWheelUp>"
  end
end

local mouse_scroll_down = function(prompt_bufnr)
  local action_state = require("telescope.actions.state")
  local actions = require("telescope.actions")
  local picker = action_state.get_current_picker(prompt_bufnr)

  local mouse_win = vim.fn.getmousepos().winid
  local win_info = vim.api.nvim_win_call(mouse_win, vim.fn.winsaveview)
  if mouse_win == picker.results_win then
    if
      win_info.topline
      < (
        vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(mouse_win))
        - vim.api.nvim_win_get_height(mouse_win)
      )
    then
      schedule_if_buf_valid(prompt_bufnr, function()
        actions.results_scrolling_down(prompt_bufnr)
        picker:set_selection(vim.fn.getmousepos().line - 1)
      end)
    end
    return ""
  elseif mouse_win == picker.preview_win then
    schedule_if_buf_valid(prompt_bufnr, function()
      actions.preview_scrolling_down(prompt_bufnr)
    end)
    return ""
  else
    return "<ScrollWheelDown>"
  end
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

local double_mouse_click = function(prompt_bufnr)
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local picker = action_state.get_current_picker(prompt_bufnr)

  local pos = vim.fn.getmousepos()
  if pos and pos.winid == picker.results_win then
    schedule_if_buf_valid(prompt_bufnr, function()
      picker:set_selection(pos.line - 1)
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

local function convert_telescope_entry(item)
  local path
  if item.Path and not item.filename then
    -- item.filename = item[1]:gsub(item.cwd, "")
    item.filename = item.Path:normalize(item.cwd)
    path = item.Path
    item.Path = nil
  end

  path = path or require("plenary.path"):new(item.filename)

  if path:is_dir() then
    return
  end

  local row = (item.lnum or 1) - 1
  local col = (item.col or 1) - 1

  if not item.bufnr then
    local fname = path:absolute()
    if vim.fn.filereadable(fname) == 0 then
      return
    end
    item.bufnr = vim.fn.bufnr(fname, true)
  end

  local pitem = {
    row = row,
    col = col,
    message = item.text,
    severity = 0,
    range = {
      start = { line = row, character = col },
      ["end"] = { line = row, character = -1 },
    },
  }

  return require("trouble.util").process_item(pitem, item.bufnr)
end

-- fixes trouble with telescope-file-browser
local function open_with_trouble(prompt_bufnr)
  local action_state = require("telescope.actions.state")
  local actions = require("telescope.actions")

  local picker = action_state.get_current_picker(prompt_bufnr)

  require("trouble.providers.telescope").results = {}
  local results = require("trouble.providers.telescope").results

  local multi_selection = picker:get_multi_selection()

  local iter
  if #multi_selection > 0 then
    iter = vim.iter(multi_selection)
  else
    iter = picker.manager:iter()
  end

  for item in iter do
    local result = convert_telescope_entry(item)
    if result then
      table.insert(results, result)
    end
  end

  actions.close(prompt_bufnr)
  vim.cmd.stopinsert({ bang = true })
  require("trouble").open("telescope")
end

local function add_to_harpoon(prompt_bufnr)
  local action_state = require("telescope.actions.state")

  local picker = action_state.get_current_picker(prompt_bufnr)

  local multi_selection = picker:get_multi_selection()

  local iter
  if #multi_selection > 0 then
    iter = vim.iter(multi_selection)
  else
    iter = vim.iter({ picker:get_selection() })
  end

  local list = require("harpoon"):list()

  for file in iter do
    if file.filename and file.filename ~= "" then
      list:append(file.filename)
    else
      vim.notify(
        "No filename found for " .. vim.inspect(file),
        vim.log.levlels.ERROR,
        {}
      )
    end
  end
end

local function create_and_add_to_harpoon(prompt_bufnr)
  local fb_actions = telescope.extensions.file_browser.actions
  local path = fb_actions.create(prompt_bufnr)
  if path ~= nil then
    require("harpoon"):list():append(path)
  end
end

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
        ["<scrollwheeldown>"] = {
          mouse_scroll_down,
          type = "action",
          opts = { expr = true },
        },
        ["<scrollwheelup>"] = {
          mouse_scroll_up,
          type = "action",
          opts = { expr = true },
        },
        ["<leftmouse>"] = {
          mouse_click,
          type = "action",
          opts = { expr = true },
        },
        ["<2-LeftMouse>"] = {
          double_mouse_click,
          type = "action",
          opts = { expr = true },
        },
        ["<C-t>"] = { open_with_trouble, type = "action" },
      },
      n = {
        ["<MouseMove>"] = {
          mouse_move,
          type = "action",
          opts = { expr = true },
        },
        ["<ScrollWheelDown>"] = {
          mouse_scroll_up,
          type = "action",
          opts = { expr = true },
        },
        ["<ScrollWheelUp>"] = {
          mouse_scroll_down,
          type = "action",
          opts = { expr = true },
        },
        ["<LeftMouse>"] = {
          mouse_click,
          type = "action",
          opts = { expr = true },
        },
        ["<2-LeftMouse>"] = {
          double_mouse_click,
          type = "action",
          opts = { expr = true },
        },
        ["<C-t>"] = { open_with_trouble, type = "action" },
      },
    },
  },
  extensions = {
    file_browser = {
      mappings = {
        ["i"] = {
          ["<C-a>"] = add_to_harpoon,
          ["<C-n>"] = create_and_add_to_harpoon,
          ["<C-t>"] = {
            open_with_trouble,
            type = "action",
            desc = "Open with Trouble",
          },
        },
        ["n"] = {
          ["c"] = create_and_add_to_harpoon,
          ["<C-a>"] = add_to_harpoon,
          ["<C-t>"] = {
            open_with_trouble,
            type = "action",
            desc = "Open with Trouble",
          },
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

local extensions = {
  "fzf",
  "frecency",
  "smart_history",
  -- "menufacture",
  -- "neoclip",
  -- "file_browser",
  -- "projects",
  -- "noice",
  -- "macros",
  -- "scope",
  -- "yank_history",
  -- "attempt",
  -- "bookmarks",
}

for _, ext in ipairs(extensions) do
  telescope.load_extension(ext)
end
