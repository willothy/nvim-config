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
    "willothy/flatten.nvim",
    -- dir = "~/projects/lua/flatten/",
    cond = true,
    opts = {
      window = {
        open = "alternate",
      },
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
