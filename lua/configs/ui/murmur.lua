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
      vim.api.nvim_exec_autocmds("User", { pattern = "MurmurDiagnostics" })
      vim.w.diag_shown = false
    end,
  },
})

local enabled = true
vim.api.nvim_create_user_command("MurmurToggle", function()
  enabled = not enabled
end, { nargs = 0 })

local au = vim.api.nvim_create_augroup("murmur_au", { clear = true })

-- To create IDE-like no blinking diagnostic message with `cursor` scope. (should be paired with the callback above)
vim.api.nvim_create_autocmd("CursorHold", {
  group = au,
  pattern = "*",
  callback = function()
    -- skip when a float-win already exists.
    if vim.w.diag_shown then return end

    -- open float-win when hovering on a cursor-word.
    if vim.w.cursor_word ~= "" and enabled then
      local buf = vim.diagnostic.open_float({
        scope = "cursor",
        close_events = {
          "InsertEnter",
          "User MurmurDiagnostics",
          "BufLeave",
        },
      })

      vim.api.nvim_create_autocmd({ "WinClosed" }, {
        group = au,
        buffer = buf,
        once = true,
        callback = function()
          vim.w.diag_shown = false
        end,
      })
      vim.w.diag_shown = true
    else
      vim.w.diag_shown = false
    end
  end,
})
