local telescope = require("telescope")

local open_win = function(enter, width, height, row, col, title, border)
  -- local has_title = type(title) == "string" or type(title) == "table"
  -- if not has_title then
  --   vim.print(title)
  -- end
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
    title = title and title or nil,
    title_pos = title and "center" or nil,
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
    local hide_preview = vim.o.columns < 80
    local height = math.floor((vim.o.lines / 2) + 0.5) - 2
    local preview_ratio = willothy.fn.map_range(80, 150, 3, 2, vim.o.columns)

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
        width = preview_width - 1,
        height = height - 1,
        row = vim.o.lines - height - 2,
        col = results_width + 2,
        border = {
          "│",
          " ",
          " ",
          " ",
          " ",
          " ",
          "│",
          "│",
        },
      }
    end
    res.prompt = {
      width = results_width,
      height = 1,
      row = math.floor(vim.o.lines / 2),
      col = 0,
      border = {
        " ",
        " ",
        " ",
        " ",
        "─",
        "─",
        "─",
        " ",
      },
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
      picker.results_title
    )
    if c.preview then
      self.preview = open_win(
        false,
        c.preview.width,
        c.preview.height,
        c.preview.row,
        c.preview.col,
        picker.preview_title,
        c.preview.border
      )
    end
    self.prompt = open_win(
      true,
      c.prompt.width,
      c.prompt.height,
      c.prompt.row,
      c.prompt.col,
      picker.prompt_title,
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
        picker.preview_title
      )
    elseif not c.preview and self.preview then
      close_win(self.preview)
      self.preview = nil
    end
    update_win(self.prompt, c.prompt)
  end

  function layout:unmount()
    close_win(self.results)
    if self.preview then
      close_win(self.preview)
    end
    close_win(self.prompt)
  end

  return Layout(layout)
end

local flexible = function(picker)
  local Layout = require("telescope.pickers.layout")

  local function get_configs()
    local width = math.min(math.floor(vim.o.columns / 6) * 5, 120)
    local height = math.floor((vim.o.lines / 3) + 0.5) * 2

    local preview_ratio =
      willothy.fn.map_range(100, 150, 3, 2.2, vim.o.columns)

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
          col = col + results_width + 2,
          border = {
            "│",
            " ",
            " ",
            " ",
            " ",
            " ",
            "│",
            "│",
          },
        },
        prompt = {
          width = results_width + 1,
          height = 1,
          row = row + height - 1,
          col = col,
          border = {
            "─",
            "─",
            "┤",
            "│",
            "│",
            " ",
            " ",
            " ",
          },
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
          row = row - 2,
          col = col,
          border = {
            " ",
            " ",
            " ",
            " ",
            "─",
            "─",
            "─",
            " ",
          },
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
      picker.results_title
    )
    if c.preview then
      self.preview = open_win(
        false,
        c.preview.width,
        c.preview.height,
        c.preview.row,
        c.preview.col,
        picker.preview_title,
        c.preview.border
      )
    end
    self.prompt = open_win(
      true,
      c.prompt.width,
      c.prompt.height,
      c.prompt.row,
      c.prompt.col,
      picker.propmt_title,
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
        picker.preview_title or "Preview"
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

local sched_if_valid = function(buf, fn)
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then
      fn()
    end
  end)
end

local mouse_scroll_up = function(prompt_bufnr)
  local action_state = require("telescope.actions.state")
  local actions = require("telescope.actions")
  local picker = action_state.get_current_picker(prompt_bufnr)

  local mouse_win = vim.fn.getmousepos().winid
  if picker.results_win == mouse_win then
    local win_info = vim.api.nvim_win_call(mouse_win, vim.fn.winsaveview)
    if win_info.topline > 1 then
      sched_if_valid(prompt_bufnr, function()
        -- picker:set_selection(vim.fn.getmousepos().line - 1)
        actions.results_scrolling_up(prompt_bufnr)
      end)
    end
    return ""
  elseif mouse_win == picker.preview_win then
    sched_if_valid(prompt_bufnr, function()
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
      sched_if_valid(prompt_bufnr, function()
        actions.results_scrolling_down(prompt_bufnr)
        picker:set_selection(vim.fn.getmousepos().line - 1)
      end)
    end
    return ""
  elseif mouse_win == picker.preview_win then
    sched_if_valid(prompt_bufnr, function()
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
    sched_if_valid(prompt_bufnr, function()
      picker:set_selection(pos.line - 1)
    end)
  elseif pos and pos.winid == picker.preview_win then
    sched_if_valid(prompt_bufnr, function()
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
    sched_if_valid(prompt_bufnr, function()
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
    sched_if_valid(prompt_bufnr, function()
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
    create_layout = flexible,
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
      create_layout = bottom_pane,
      display_stat = false,
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
