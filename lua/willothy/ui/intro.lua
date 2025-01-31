if vim.fn.argc() > 0 or vim.tbl_isempty(vim.api.nvim_list_uis()) then
  return
end

local augroup = vim.api.nvim_create_augroup("NvimIntro", { clear = true })

local winid
local bg_winid

---@class intro_chunk_t
---@field text string
---@field hl string
---@field len integer? byte-indexed text length
---@field width integer? display width of text

---@class intro_line_t
---@field chunks intro_chunk_t[]
---@field text string?
---@field width integer?
---@field offset integer?

local M = {}

local saved_opts = {}

local function save_opts(opts)
  for opt, val in pairs(opts) do
    if not saved_opts[opt] then
      saved_opts[opt] = vim.o[opt]
    end
    vim.o[opt] = val
  end
end

local function restore_opts()
  for k, v in pairs(saved_opts) do
    vim.o[k] = v
    saved_opts[k] = nil
  end
end

local function gen_lines()
  local stats = require("lazy").stats()
  local version = vim.version()

  ---Lines of text and highlight groups to display as intro message
  ---@type intro_line_t[]
  local lines = {
    {
      chunks = {
        {
          text = "Neovim",
          hl = "Identifier",
        },
        {
          text = " :: ",
          hl = "Comment",
        },
        {
          text = tostring(version),
          hl = "Identifier",
        },
      },
    },
    {
      chunks = {
        {
          text = string.format("%d/%d plugins", stats.loaded, stats.count),
          hl = "Comment",
        },
        {
          text = " :: ",
          hl = "Comment",
        },
        {
          text = "startup in "
            .. string.format("%.2f", stats.startuptime)
            .. "ms",
          hl = "Comment",
        },
      },
    },
  }

  return lines
end

function M.update()
  if winid and not vim.api.nvim_win_is_valid(winid) then
    winid = nil
    return
  end

  local lines = gen_lines()

  ---Window configuration for the intro message floating window
  ---@type vim.api.keyset.win_config
  local win_config = winid and vim.api.nvim_win_get_config(winid)
    or {
      width = 0,
      height = #lines,
      relative = "editor",
      style = "minimal",
      focusable = false,
      noautocmd = true,
      zindex = 1,
    }

  ---Calculate the width, offset, concatenated text, etc.
  for _, line in ipairs(lines) do
    line.text = ""
    line.width = 0
    for _, chunk in ipairs(line.chunks) do
      chunk.len = #chunk.text
      chunk.width = vim.fn.strdisplaywidth(chunk.text)
      line.text = line.text .. chunk.text
      line.width = line.width + chunk.width
    end
    if line.width > win_config.width then
      win_config.width = line.width
    end
  end

  for _, line in ipairs(lines) do
    line.offset = math.floor((win_config.width - line.width) / 2)
  end

  -- Decide the row and col offset of the floating window,
  -- return if no enough space
  win_config.row =
    math.floor((vim.go.lines - vim.go.ch - win_config.height) / 2)
  win_config.col = math.floor((vim.go.columns - win_config.width) / 2)
  if win_config.row < 4 or win_config.col < 8 then
    return
  end

  local buf = vim.api.nvim_win_get_buf(winid)

  vim.api.nvim_buf_set_lines(
    buf,
    0,
    -1,
    false,
    vim.tbl_map(function(line)
      return string.rep(" ", line.offset) .. line.text
    end, lines)
  )

  -- Apply highlight groups
  local ns = vim.api.nvim_create_namespace("NvimIntro")
  for linenr, line in ipairs(lines) do
    local chunk_offset = line.offset
    for _, chunk in ipairs(line.chunks) do
      vim.highlight.range(
        buf,
        ns,
        chunk.hl,
        { linenr - 1, chunk_offset },
        { linenr - 1, chunk_offset + chunk.len },
        {}
      )
      chunk_offset = chunk_offset + chunk.len
    end
  end

  vim.api.nvim__redraw({
    win = winid,
    valid = true,
  })
end

local function show()
  if winid and vim.api.nvim_win_is_valid(winid) then
    return
  end

  local lines = gen_lines()

  ---Window configuration for the intro message floating window
  ---@type vim.api.keyset.win_config
  local win_config = winid and vim.api.nvim_win_get_config(winid)
    or {
      width = 0,
      height = #lines,
      relative = "editor",
      style = "minimal",
      focusable = false,
      noautocmd = true,
      zindex = 1,
    }

  ---Calculate the width, offset, concatenated text, etc.
  for _, line in ipairs(lines) do
    line.text = ""
    line.width = 0
    for _, chunk in ipairs(line.chunks) do
      chunk.len = #chunk.text
      chunk.width = vim.fn.strdisplaywidth(chunk.text)
      line.text = line.text .. chunk.text
      line.width = line.width + chunk.width
    end
    if line.width > win_config.width then
      win_config.width = line.width
    end
  end

  for _, line in ipairs(lines) do
    line.offset = math.floor((win_config.width - line.width) / 2)
  end

  -- Decide the row and col offset of the floating window,
  -- return if no enough space
  win_config.row =
    math.floor((vim.go.lines - vim.go.ch - win_config.height) / 2)
  win_config.col = math.floor((vim.go.columns - win_config.width) / 2)
  if win_config.row < 4 or win_config.col < 8 then
    return
  end

  -- Create the scratch buffer to display the intro message
  -- Set eventignore to avoid triggering plugin lazy-loading handlers
  local eventignore = vim.go.eventignore
  vim.opt.eventignore:append({
    "BufNew",
    "OptionSet",
    "TextChanged",
    "BufModifiedSet",
  })

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false

  vim.api.nvim_buf_set_lines(
    buf,
    0,
    -1,
    false,
    vim.tbl_map(function(line)
      return string.rep(" ", line.offset) .. line.text
    end, lines)
  )

  -- Apply highlight groups
  local ns = vim.api.nvim_create_namespace("NvimIntro")
  for linenr, line in ipairs(lines) do
    local chunk_offset = line.offset
    for _, chunk in ipairs(line.chunks) do
      vim.highlight.range(
        buf,
        ns,
        chunk.hl,
        { linenr - 1, chunk_offset },
        { linenr - 1, chunk_offset + chunk.len },
        {}
      )
      chunk_offset = chunk_offset + chunk.len
    end
  end

  vim.go.eventignore = eventignore

  -- Open the window to show the intro message
  local win = vim.api.nvim_open_win(buf, false, win_config)
  vim.wo[win].winhl = "NormalFloat:Normal"

  winid = win
  bg_winid =
    vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), false, {
      relative = "editor",
      style = "minimal",
      row = 0,
      col = 0,
      width = vim.o.columns,
      height = vim.o.lines - 1,
      focusable = false,
      mouse = false,
      noautocmd = true,
      zindex = 1,
    })
  vim.wo[bg_winid].winhl = "NormalFloat:Normal"

  save_opts({
    -- laststatus = 0,
    -- showtabline = 0,
    number = false,
    relativenumber = false,
    guicursor = "a:NoiceHiddenCursor",
  })
  saved_opts.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
  require("willothy.ui.cursor").hide_cursor()

  vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
    group = augroup,
    callback = vim.schedule_wrap(function()
      if vim.api.nvim_get_mode().mode == "c" then
        vim.go.guicursor = saved_opts.guicursor
        require("willothy.ui.cursor").show_cursor()
      else
        vim.go.guicursor = "a:NoiceHiddenCursor"
        require("willothy.ui.cursor").hide_cursor()
      end
    end),
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = { "LazyLoad", "LazyLoaded", "LazyDone" },
    group = augroup,
    callback = function()
      M.update()
    end,
  })

  vim.api.nvim_create_autocmd({
    "BufModifiedSet",
    "BufReadPre",
    -- "CmdlineEnter",
    "CursorMoved",
    "InsertEnter",
    "TermOpen",
    "TextChanged",
    "VimResized",
    "WinEnter",
    "BufEnter",
  }, {
    once = true,
    group = augroup,
    callback = M.hide,
  })
end

local function hide()
  restore_opts()
  require("willothy.ui.cursor").show_cursor()
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_win_close(winid, true)
  end
  if bg_winid and vim.api.nvim_win_is_valid(bg_winid) then
    vim.api.nvim_win_close(bg_winid, true)
  end
  winid = nil
  bg_winid = nil

  augroup = vim.api.nvim_create_augroup("NvimIntro", { clear = true })
end

function M.show()
  -- Snacks.dashboard()
  show()
end

function M.hide()
  -- Snacks.dashboard.Dashboard:action("close")
  hide()
end

return M

-- local function show()
--   -- require("snacks").dashboard.open()
--
--   -- vim.api.nvim_create_autocmd("User", {
--   --   pattern = { "LazyLoad", "LazyLoaded", "LazyDone" },
--   --   callback = function()
--   --     Snacks.dashboard.update()
--   --   end,
--   -- })
-- end
--
-- local function hide()
--   -- Snacks.dashboard.open()
-- end
--
-- return {
--   show = show,
--   hide = hide,
-- }
