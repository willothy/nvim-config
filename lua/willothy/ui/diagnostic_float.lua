-- IDE-like, flicker-free diagnostic popup.
--
-- On CursorHold, show a cursor-scoped `vim.diagnostic` float. Keep it open
-- while the cursor stays on the same word (so it doesn't blink), and close it
-- when the word changes (CursorMoved), you start editing, or leave the buffer.
-- Diagnostics in the top-right corner are still handled separately by diagflow.
local M = {}

local au =
  vim.api.nvim_create_augroup("willothy_diagnostic_float", { clear = true })
local enabled = true
local active_win
local active_word

function M.hide()
  if active_win and vim.api.nvim_win_is_valid(active_win) then
    vim.api.nvim_win_close(active_win, true)
  end
  active_win = nil
  active_word = nil
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
  -- already showing (don't reopen -> no flicker), or disabled
  if (active_win and vim.api.nvim_win_is_valid(active_win)) or not enabled then
    return
  end

  -- only when the cursor is on a word
  local word = vim.fn.expand("<cword>")
  if word == "" then
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
  active_word = word

  vim.api.nvim_create_autocmd("WinClosed", {
    group = au,
    buffer = buf,
    once = true,
    callback = function()
      active_win = nil
      active_word = nil
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

  -- close once the cursor leaves the word the float was opened for
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = au,
    pattern = "*",
    callback = function()
      if active_win and vim.fn.expand("<cword>") ~= active_word then
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
