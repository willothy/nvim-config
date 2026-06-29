-- IDE-like, flicker-free diagnostic popup.
--
-- On CursorHold, show a cursor-scoped `vim.diagnostic` float while the cursor
-- is within a diagnostic's range. Keep it open while the cursor stays inside
-- that range (so it doesn't blink), and close it as soon as the cursor leaves
-- the diagnostic, starts editing, or leaves the buffer. Diagnostics in the
-- top-right corner are still handled separately by diagflow.
local M = {}

local au =
  vim.api.nvim_create_augroup("willothy_diagnostic_float", { clear = true })
local enabled = true
local active_win

-- Is the cursor inside the range of any diagnostic (i.e. over its underline)?
local function over_diagnostic()
  local pos = vim.api.nvim_win_get_cursor(0)
  local lnum, col = pos[1] - 1, pos[2]
  for _, d in ipairs(vim.diagnostic.get(0)) do
    local end_lnum = d.end_lnum or d.lnum
    local end_col = (d.end_col and d.end_col > d.col) and d.end_col
      or (d.col + 1)
    local after_start = lnum > d.lnum or (lnum == d.lnum and col >= d.col)
    local before_end = lnum < end_lnum or (lnum == end_lnum and col < end_col)
    if after_start and before_end then
      return true
    end
  end
  return false
end

function M.hide()
  if active_win and vim.api.nvim_win_is_valid(active_win) then
    vim.api.nvim_win_close(active_win, true)
  end
  active_win = nil
end

function M.enable()
  enabled = true
end

function M.disable()
  enabled = false
  M.hide()
end

function M.toggle()
  enabled = not enabled
  if not enabled then
    M.hide()
  end
end

function M.show()
  -- already showing (don't reopen -> no flicker), disabled, or not over a
  -- diagnostic
  if
    (active_win and vim.api.nvim_win_is_valid(active_win))
    or not enabled
    or not over_diagnostic()
  then
    return
  end

  -- don't fight an open LSP hover (noice)
  local ok, docs = pcall(require, "noice.lsp.docs")
  if ok and docs.get("hover"):win() ~= nil then
    return
  end

  local buf, win = vim.diagnostic.open_float({
    scope = "cursor",
    close_events = {
      "InsertEnter",
      "TextChanged",
      "BufLeave",
    },
  })
  if not buf or not win then
    return
  end
  active_win = win

  vim.api.nvim_create_autocmd("WinClosed", {
    group = au,
    buffer = buf,
    once = true,
    callback = function()
      active_win = nil
    end,
  })
end

function M.setup()
  -- show after the cursor rests
  vim.api.nvim_create_autocmd("CursorHold", {
    group = au,
    pattern = "*",
    callback = M.show,
  })

  -- close as soon as the cursor leaves the diagnostic's range
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = au,
    pattern = "*",
    callback = function()
      if active_win and not over_diagnostic() then
        M.hide()
      end
    end,
  })

  -- hide the diagnostic float whenever an LSP hover is requested (noice)
  local ok, docs = pcall(require, "noice.lsp.docs")
  if ok then
    local get = docs.get
    ---@diagnostic disable-next-line: duplicate-set-field
    docs.get = function(name)
      if name == "hover" then
        M.hide()
      end
      return get(name)
    end
  end

  -- <leader>uF toggle via snacks
  local ok_snacks, Snacks = pcall(require, "snacks")
  if ok_snacks then
    Snacks.toggle
      .new({
        name = "Diagnostic float",
        get = function()
          return enabled
        end,
        set = function(value)
          enabled = value
          if enabled then
            M.show()
          else
            M.hide()
          end
        end,
      })
      :map("<leader>uF")
  end

  return M
end

return M
