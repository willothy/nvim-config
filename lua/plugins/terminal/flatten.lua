local function toggle_terminal()
  -- Main toggleterm terminal
  require("willothy.terminals").main:toggle()

  -- Generic toggleterm
  -- require("toggleterm").toggle(0)

  -- NVTerm
  -- require("nvterm.terminal").toggle("horizontal")
end

return {
  {
    -- "willothy/flatten.nvim",
    "IndianBoy42/flatten.nvim",
    branch = "misc",
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
        if vim.env.NVIM then return vim.env.NVIM end
        -- If running in a Kitty terminal,
        -- all tabs/windows/os-windows in the same instance of kitty will open in the first neovim instance
        if vim.env.WEZTERM_UNIX_SOCKET then
          local list = vim.json.decode(
            vim
              .system({ "wezterm", "cli", "list", "--format", "json" })
              :wait().stdout
          )
          local cur_tab
          for _, pane in ipairs(list) do
            if pane.pane_id == tonumber(vim.env.WEZTERM_PANE) then
              cur_tab = pane.tab_id
              break
            end
          end
          local addr = ("%s/%s"):format(
            vim.fn.stdpath("run"),
            "wezterm.nvim-"
              .. vim.env.WEZTERM_UNIX_SOCKET:match("gui%-sock%-(%d+)")
              .. "-"
              .. cur_tab
          )
          if not vim.loop.fs_stat(addr) then vim.fn.serverstart(addr) end
          return addr
        end
      end,
      callbacks = {
        should_block = function(argv) return vim.tbl_contains(argv, "-b") end,
        post_open = function(bufnr, winnr, ft, is_blocking)
          if is_blocking or ft == "gitcommit" or ft == "gitrebase" then
            -- Hide the terminal while it's blocking
            toggle_terminal()
          else
            -- If it's a normal file, just switch to its window
            vim.api.nvim_set_current_win(winnr)
          end

          -- If the file is a git commit, create one-shot autocmd to delete its buffer on write
          -- If you just want the toggleable terminal integration, ignore this bit
          if ft == "gitcommit" or ft == "gitrebase" then
            vim.api.nvim_create_autocmd("BufWritePost", {
              buffer = bufnr,
              once = true,
              callback = function()
                -- This is a bit of a hack, but if you run bufdelete immediately
                -- the shell can occasionally freeze
                vim.defer_fn(
                  function() vim.api.nvim_buf_delete(bufnr, {}) end,
                  50
                )
              end,
            })
          end
        end,
        block_end = function()
          -- After blocking ends (for a git commit, etc), reopen the terminal
          vim.defer_fn(toggle_terminal, 50)
        end,
      },
    },
  },
}
