local M = {}

-- Create reactive system instance
local rx = require("willothy.lib.reactive").create_system()
M.rx = rx

-- Global reactive state (flat structure for performance)
-- Mode information (mode string, colors, etc)
local mode_get, mode_set = rx.signal({ mode = "n", color = { fg = nil, bg = nil }, short_name = "N" })
M.mode = { get = mode_get, set = mode_set }

-- Git branch name
local git_branch_get, git_branch_set = rx.signal(nil)
M.git_branch = { get = git_branch_get, set = git_branch_set }

-- Global diagnostic counts
local diagnostics_get, diagnostics_set = rx.signal({ errors = 0, warnings = 0, info = 0, hints = 0 })
M.diagnostics = { get = diagnostics_get, set = diagnostics_set }

-- Buffer-scoped state (lazily created, flattened)
M.buffer_git_status = setmetatable({}, {
  __index = function(t, bufnr)
    local get, set = rx.signal(nil)
    local signal = { get = get, set = set }
    rawset(t, bufnr, signal)
    return signal
  end,
})

M.buffer_diagnostics = setmetatable({}, {
  __index = function(t, bufnr)
    local get, set = rx.signal({})
    local signal = { get = get, set = set }
    rawset(t, bufnr, signal)
    return signal
  end,
})

-- Window-scoped state (lazily created, flattened)
M.window_cursor = setmetatable({}, {
  __index = function(t, winid)
    local get, set = rx.signal({ line = 1, col = 0 })
    local signal = { get = get, set = set }
    rawset(t, winid, signal)
    return signal
  end,
})

-- Computed values (reactive - automatically update when dependencies change)
M.computed = {
  -- Current mode info with colors and display name
  mode_info = function()
    local mode = M.mode.get()
    return {
      mode = mode.mode,
      color = mode.color,
      short_name = mode.short_name,
    }
  end,

  -- Diagnostic summary string
  diagnostic_summary = function()
    local diags = M.diagnostics.get()
    return string.format(
      "E:%d W:%d I:%d H:%d",
      diags.errors,
      diags.warnings,
      diags.info,
      diags.hints
    )
  end,

  -- Combined statusline data (for UI components)
  statusline_data = function()
    return {
      mode = M.computed.mode_info(),
      git = M.git_branch.get(),
      diagnostics = M.computed.diagnostic_summary(),
    }
  end,
}

-- Cleanup functions for when buffers/windows are closed
function M.cleanup_buffer(bufnr)
  rawset(M.buffer_git_status, bufnr, nil)
  rawset(M.buffer_diagnostics, bufnr, nil)
end

function M.cleanup_window(winid)
  rawset(M.window_cursor, winid, nil)
end

return M
