local active_win

require("murmur").setup({
  exclude_filetypes = {
    "harpoon",
    "neo-tree",
    "noice",
    "SidebarNvim",
    "terminal",
    "Trouble",
  },
  cursor_rgb = "Cursorword",
  cursor_rgb_current = "CursorwordCurrent",
  cursor_rgb_always_use_config = true,
  callbacks = {
    function()
      if active_win and vim.api.nvim_win_is_valid(active_win) then
        vim.api.nvim_win_close(active_win, true)
      end
      active_win = nil
    end,
  },
})

local enabled = true
vim.api.nvim_create_user_command("DiagnosticFloat", function()
  enabled = not enabled
end, { nargs = 0 })

local au = vim.api.nvim_create_augroup("murmur_au", { clear = true })

-- To create IDE-like no blinking diagnostic message with `cursor` scope. (should be paired with the callback above)
vim.api.nvim_create_autocmd("CursorHold", {
  group = au,
  pattern = "*",
  callback = function()
    -- skip when a float-win already exists.
    if active_win and vim.api.nvim_win_is_valid(active_win) then
      return
    end

    -- open float-win when hovering on a cursor-word.
    if vim.w.cursor_word ~= "" and enabled then
      local buf, win = vim.diagnostic.open_float({
        scope = "cursor",
        close_events = {
          "InsertEnter",
          "BufLeave",
        },
      })
      active_win = win

      vim.api.nvim_create_autocmd({ "WinClosed" }, {
        group = au,
        buffer = buf,
        once = true,
        callback = function()
          active_win = nil
        end,
      })
    end
  end,
})
