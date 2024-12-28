local function lazy(module)
  return setmetatable({}, {
    __index = function(_, key)
      return require(module)[key]
    end,
    __call = function(_, ...)
      return require(module)(...)
    end,
  })
end

---@module "telescope.pickers.layout"
local Layout = lazy("telescope.pickers.layout")

---@param enter boolean
---@param opts vim.api.keyset.win_config
---@return TelescopeWindow
local open_win = function(enter, opts)
  local bufnr = vim.api.nvim_create_buf(false, true)

  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].buflisted = false

  local config = vim.tbl_deep_extend(
    "force",
    {
      relative = "editor",
      row = 0,
      col = 0,
      width = 40,
      height = 10,
    },
    opts,
    {
      style = "minimal",
    }
  )

  if
    (config.title or config.footer)
    and (config.border == nil or config.border == "none")
  then
    config.border = "solid"
  end

  local winid = vim.api.nvim_open_win(bufnr, enter, config)

  return Layout.Window({
    bufnr = bufnr,
    winid = winid,
  })
end

local close_win = function(window)
  if window and window.winid and vim.api.nvim_win_is_valid(window.winid) then
    vim.api.nvim_win_close(window.winid, true)
  end
end

local update_win = function(window, opts)
  if window and window.winid and vim.api.nvim_win_is_valid(window.winid) then
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

---@class TelescopeLayouts
---@field [string] fun(picker: table): TelescopeLayout
local M = {}

function M.bottom_pane(picker)
  local function get_configs()
    local hide_preview = vim.o.columns < 80
    local height = math.floor((vim.o.lines / 2) + 0.5) - 2
    local preview_ratio =
      require("willothy.lib.fn").map_range(80, 150, 3, 2, vim.o.columns)

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
    self.results = open_win(false, {
      width = c.results.width,
      height = c.results.height,
      row = c.results.row,
      col = c.results.col,
      title = picker.results_title or "",
      title_pos = "center",
    })
    if c.preview then
      self.preview = open_win(false, {
        width = c.preview.width,
        height = c.preview.height,
        row = c.preview.row,
        col = c.preview.col,
        title = picker.preview_title or "",
        title_pos = "center",
        border = c.preview.border,
      })
    end
    self.prompt = open_win(true, {
      width = c.prompt.width,
      height = c.prompt.height,
      row = c.prompt.row,
      col = c.prompt.col,
      title = picker.prompt_title or "",
      title_pos = "center",
      border = c.prompt.border,
    })
  end

  function layout:update()
    local c = get_configs()
    update_win(self.results, c.results)
    if self.preview and c.preview then
      update_win(self.preview, c.preview)
    elseif c.preview and not self.preview then
      self.preview = open_win(false, {
        width = c.preview.width,
        height = c.preview.height,
        row = c.preview.row,
        col = c.preview.col,
        title = picker.preview_title or "",
        title_pos = "center",
        border = c.preview.border,
      })
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

function M.flexible(picker)
  local function get_configs()
    local width = math.floor(vim.o.columns / 6) * 5
    local height = math.floor((vim.o.lines / 3) + 0.5) * 2

    local preview_ratio =
      require("willothy.lib.fn").map_range(100, 150, 3, 2.2, vim.o.columns)

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
    self.results = open_win(false, {
      width = c.results.width,
      height = c.results.height,
      row = c.results.row,
      col = c.results.col,
      title = picker.results_title or "",
      title_pos = "center",
    })
    if c.preview then
      self.preview = open_win(false, {
        width = c.preview.width,
        height = c.preview.height,
        row = c.preview.row,
        col = c.preview.col,
        title = picker.preview_title or "",
        title_pos = "center",
        border = c.preview.border,
      })
    end
    self.prompt = open_win(true, {
      width = c.prompt.width,
      height = c.prompt.height,
      row = c.prompt.row,
      col = c.prompt.col,
      title = picker.prompt_title or "",
      title_pos = "center",
      border = c.prompt.border,
    })
  end

  function layout:update()
    local c = get_configs()
    update_win(self.results, c.results)
    if self.preview and c.preview then
      update_win(self.preview, c.preview)
    elseif c.preview and not self.preview then
      self.preview = open_win(false, {
        width = c.preview.width,
        height = c.preview.height,
        row = c.preview.row,
        col = c.preview.col,
        title = picker.preview_title or "",
        title_pos = "center",
        border = c.preview.border,
      })
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

return M
