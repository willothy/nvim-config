require("toggleterm").setup({
  start_in_insert = false,
  close_on_exit = true,
  shade_terminals = false,
  auto_scroll = false,
  persist_size = false,
  on_create = function(term)
    vim.bo[term.bufnr].filetype = "terminal"
    local win
    vim.api.nvim_create_autocmd("BufEnter", {
      buffer = term.bufnr,
      callback = function()
        win = vim.api.nvim_get_current_win()
      end,
    })
    vim.api.nvim_create_autocmd("TermClose", {
      buffer = term.bufnr,
      once = true,
      callback = function()
        -- when leaving, open another terminal buffer in the same window
        local terms = vim
          .iter(vim.api.nvim_list_bufs())
          :filter(function(buf)
            return vim.bo[buf].buftype == "terminal" and buf ~= term.bufnr
          end)
          :totable()

        local win_bufs = vim
          .iter(vim.api.nvim_list_wins())
          :map(vim.api.nvim_win_get_buf)
          :fold({}, function(acc, v)
            acc[v] = v
            return acc
          end)

        local target
        for _, t in ipairs(terms) do
          -- fall back to the first term if no hidden terms are found
          target = target or t
          if win_bufs[t] == nil then
            target = t -- use the first hidden term if found
            break
          end
        end

        if win and target and vim.api.nvim_buf_is_valid(target) then
          vim.api.nvim_win_set_buf(win, target)
          vim.api.nvim_create_autocmd("WinEnter", {
            once = true,
            callback = vim.schedule_wrap(function()
              if win and vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_set_current_win(win)
                win = nil
              end
            end),
          })
        end
      end,
    })
  end,
})
