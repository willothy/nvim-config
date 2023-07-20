local function toggle_terminal()
  -- Main toggleterm terminal
  require("willothy.terminals").main:toggle()

  -- Generic toggleterm
  -- require("toggleterm").toggle(0)

  -- NVTerm
  -- require("nvterm.terminal").toggle("horizontal")
end

local function defer_delete(ev)
  -- This is a bit of a hack, but if you run bufdelete immediately
  -- the shell can occasionally freeze
  vim.schedule(function() vim.api.nvim_buf_delete(ev.buf, {}) end)
end

return {
  {
    "willothy/flatten.nvim",
    cond = true,
    lazy = false,
    priority = 1000,
    opts = {
      window = {
        open = "alternate",
        -- open = function(files, argv, stdin_buf_id)
        --
        -- end,
      },
      pipe_path = function()
        -- If running in a terminal inside Neovim:
        local nvim = os.getenv("NVIM")
        if nvim then return nvim end

        -- If running in a Wezterm terminal,
        -- all tabs/windows/os-windows in the same instance of wezterm will open in the first neovim instance
        local wezterm = os.getenv("WEZTERM_UNIX_SOCKET")
        if not wezterm then return end

        local addr = ("%s/%s"):format(
          vim.fn.stdpath("run"),
          "wezterm.nvim-" .. wezterm:match("gui%-sock%-(%d+)")
        )
        if not vim.loop.fs_stat(addr) then vim.fn.serverstart(addr) end

        return addr
      end,
      callbacks = {
        should_block = function(argv) return vim.tbl_contains(argv, "-b") end,
        post_open = function(bufnr, winnr, ft, is_blocking)
          if is_blocking or ft == "gitcommit" or ft == "gitrebase" then
            -- Hide the terminal while it's blocking
            toggle_terminal()
          else
            -- If it's a normal file, just switch to its window
            -- If it's not in the current wezterm pane, switch to that pane.
            vim.api.nvim_set_current_win(winnr)
            require("wezterm").switch_pane.id(
              tonumber(os.getenv("WEZTERM_PANE"))
            )
          end

          -- If the file is a git commit, create one-shot autocmd to delete its buffer on write
          -- If you just want the toggleable terminal integration, ignore this bit
          if ft == "gitcommit" or ft == "gitrebase" then
            vim.api.nvim_create_autocmd("BufWritePost", {
              buffer = bufnr,
              once = true,
              callback = defer_delete,
            })
          end
        end,
        -- After blocking ends (for a git commit, etc), reopen the terminal
        block_end = vim.schedule_wrap(toggle_terminal),
      },
    },
  },
}
