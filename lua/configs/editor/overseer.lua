local opts = {
  strategy = {
    "toggleterm",
    use_shell = false,
    direction = "horizontal",
    open_on_start = false,
    close_on_exit = false,
    quit_on_exit = "success",
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
          local target = vim
            .iter(terms)
            :filter(function(term)
              return win_bufs[term] == nil
            end)
            :next() or vim.iter(terms):next()

          if target and vim.api.nvim_buf_is_valid(target) then
            vim.api.nvim_set_current_buf(target)
            vim.api.nvim_create_autocmd("WinEnter", {
              once = true,
              callback = vim.schedule_wrap(function()
                if vim.api.nvim_win_is_valid(win) then
                  vim.api.nvim_set_current_win(win)
                  win = nil
                end
              end),
            })
          end
        end,
      })
    end,
  },
  form = {
    border = "solid",
    win_opts = {
      winblend = 0,
      winhl = "FloatBorder:NormalFloat",
    },
  },
  confirm = {
    border = "solid",
    win_opts = {
      winblend = 0,
      winhl = "FloatBorder:NormalFloat",
    },
  },
  task_win = {
    border = "solid",
    win_opts = {
      winblend = 0,
      winhl = "FloatBorder:NormalFloat",
    },
  },
}

require("overseer").setup(opts)
