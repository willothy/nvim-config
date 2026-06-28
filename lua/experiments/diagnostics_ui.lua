local M = {}

-- Buffer to store diagnostic float window
local float_buf = nil
-- Window to show diagnostic float
local float_win = nil
-- Timer for debouncing diagnostic display
---@type uv_timer_t | nil
local timer = nil
-- Namespace for highlighting
local ns = vim.api.nvim_create_namespace("willothy_diagnostics_float")

local icons = {
  [vim.diagnostic.severity.ERROR] = {
    icon = "󰅚 ",
    hl = "DiagnosticFloatError",
  },
  [vim.diagnostic.severity.WARN] = {
    icon = "󰀪 ",
    hl = "DiagnosticFloatWarn",
  },
  [vim.diagnostic.severity.INFO] = {
    icon = "󰋽 ",
    hl = "DiagnosticFloatInfo",
  },
  [vim.diagnostic.severity.HINT] = {
    icon = "󰌶 ",
    hl = "DiagnosticFloatHint",
  },
}

local highlights = {
  DiagnosticFloatError = { link = "DiagnosticError" },
  DiagnosticFloatWarn = { link = "DiagnosticWarn" },
  DiagnosticFloatInfo = { link = "DiagnosticInfo" },
  DiagnosticFloatHint = { link = "DiagnosticHint" },
}

-- Get severity icon and highlight group
local function get_severity_info(severity)
  return icons[severity] or { icon = "● ", hl = "DiagnosticFloatInfo" }
end

-- Close the floating diagnostic window if it exists
local function close_float()
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_win_close(float_win, true)
    float_win = nil
  end

  if float_buf and vim.api.nvim_buf_is_valid(float_buf) then
    vim.api.nvim_buf_delete(float_buf, { force = true })
    float_buf = nil
  end
end

-- Show diagnostics in a floating window
local function show_diagnostics()
  -- Get diagnostics at current cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local line = cursor_pos[1] - 1
  local diagnostics = vim.diagnostic.get(0, { lnum = line })

  -- Close existing float if no diagnostics or in insert mode
  if #diagnostics == 0 or vim.fn.mode() == "i" then
    close_float()
    return
  end

  -- Create buffer if it doesn't exist
  if not float_buf or not vim.api.nvim_buf_is_valid(float_buf) then
    float_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = float_buf })
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = float_buf })
  end

  -- Calculate content and width
  local content = {}
  local max_width = math.floor(vim.o.columns * 0.4)
  local window_width = 0

  -- Sort diagnostics by severity
  table.sort(diagnostics, function(a, b)
    return a.severity < b.severity
  end)

  -- Process each diagnostic
  for _, diagnostic in ipairs(diagnostics) do
    local severity_info = get_severity_info(diagnostic.severity)
    local text = severity_info.icon .. diagnostic.message

    -- Calculate offset for wrapping
    local icon_width = vim.api.nvim_strwidth(severity_info.icon)
    local padding = string.rep(" ", icon_width)

    -- Wrap long lines
    local wrapped_lines = vim.fn.split(text, "\n")
    for i, line_text in ipairs(wrapped_lines) do
      if i > 1 then
        line_text = padding .. line_text
      end

      -- Handle lines longer than max_width
      if vim.api.nvim_strwidth(line_text) > max_width then
        local wrapped = {}
        local current_line = ""
        for word in line_text:gmatch("%S+") do
          local potential_line = current_line ~= ""
              and (current_line .. " " .. word)
            or word
          if vim.api.nvim_strwidth(potential_line) <= max_width then
            current_line = potential_line
          else
            table.insert(wrapped, current_line)
            current_line = i > 1 and (padding .. word) or word
          end
        end
        if current_line ~= "" then
          table.insert(wrapped, current_line)
        end
        for _j, wline in ipairs(wrapped) do
          table.insert(content, wline)
          window_width = math.max(window_width, vim.api.nvim_strwidth(wline))
        end
      else
        table.insert(content, line_text)
        window_width = math.max(window_width, vim.api.nvim_strwidth(line_text))
      end
    end
  end

  -- Set buffer content
  vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, content)

  -- Apply highlighting
  local line_idx = 0
  for _, diagnostic in ipairs(diagnostics) do
    local severity_info = get_severity_info(diagnostic.severity)
    local text = severity_info.icon .. diagnostic.message
    local icon_width = vim.api.nvim_strwidth(severity_info.icon)

    -- Calculate how many lines this diagnostic will use
    local wrapped_lines = vim.fn.split(text, "\n")
    local total_lines = 0

    for i, line_text in ipairs(wrapped_lines) do
      if i > 1 then
        line_text = string.rep(" ", icon_width) .. line_text
      end

      if vim.api.nvim_strwidth(line_text) > max_width then
        -- Calculate additional wrapped lines
        local words = {}
        for word in line_text:gmatch("%S+") do
          table.insert(words, word)
        end

        local current_line = ""
        local wrapped_count = 0

        for _, word in ipairs(words) do
          local potential_line = current_line ~= ""
              and (current_line .. " " .. word)
            or word
          if vim.api.nvim_strwidth(potential_line) <= max_width then
            current_line = potential_line
          else
            wrapped_count = wrapped_count + 1
            current_line = i > 1 and (string.rep(" ", icon_width) .. word)
              or word
          end
        end

        if current_line ~= "" then
          wrapped_count = wrapped_count + 1
        end

        total_lines = total_lines + wrapped_count
      else
        total_lines = total_lines + 1
      end
    end

    -- Apply highlight to icon
    vim.hl.range(
      float_buf,
      ns,
      severity_info.hl,
      { line_idx, 0 },
      { line_idx + total_lines - 1, icon_width },
      {}
    )

    line_idx = line_idx + total_lines
  end

  -- Calculate window position in top right
  local win_width = math.min(window_width, max_width)
  local win_height = #content

  -- Configure window options
  local win_opts = {
    relative = "editor",
    width = win_width,
    height = win_height,
    col = vim.o.columns - win_width,
    row = 2,
    anchor = "NW",
    style = "minimal",
    border = "none",
    focusable = false,
  }

  -- Create or update the floating window
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_win_set_config(float_win, win_opts)
  else
    float_win = vim.api.nvim_open_win(float_buf, false, win_opts)
    vim.api.nvim_set_option_value("winblend", 10, { win = float_win })
    vim.api.nvim_set_option_value("wrap", false, { win = float_win })

    vim.api.nvim_win_set_hl_ns(float_win, ns)

    vim.api.nvim_set_hl(ns, "Normal", {
      bg = "NONE",
      fg = "NONE",
    })
    vim.api.nvim_set_hl(ns, "NormalFloat", {
      bg = "NONE",
      fg = "NONE",
    })
  end
end

-- Update diagnostics with debouncing
function M.update_diagnostics()
  if timer then
    timer:stop()
  end

  if timer == nil or timer:is_closing() then
    timer = vim.uv.new_timer()
  end

  timer:start(
    50,
    0,
    vim.schedule_wrap(function()
      show_diagnostics()
    end)
  )
end

-- Setup function with configuration
function M.setup(opts)
  opts = opts or {}

  for group, hl in pairs(highlights) do
    if vim.fn.hlexists(group) == 0 then
      vim.api.nvim_set_hl(0, group, hl)
    end
  end

  -- Create autocommands
  local augroup =
    vim.api.nvim_create_augroup("WillothyDiagnosticsFloat", { clear = true })

  -- Update on cursor move or mode change
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorHold" }, {
    group = augroup,
    callback = M.update_diagnostics,
  })

  -- Close float in insert mode
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = augroup,
    callback = close_float,
  })

  -- Update when diagnostics change
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = augroup,
    callback = M.update_diagnostics,
  })

  -- Close float when leaving window
  vim.api.nvim_create_autocmd("WinLeave", {
    group = augroup,
    callback = close_float,
  })
end

return M
