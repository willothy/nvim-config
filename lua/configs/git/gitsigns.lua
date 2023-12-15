local bar = willothy.icons.git.signs.bar

require("gitsigns").setup({
  signs = {
    untracked = { text = bar },
    add = { text = bar },
    change = { text = bar },
    delete = { text = bar },
    topdelete = { text = bar },
    changedelete = { text = bar },
  },
  trouble = true,
  signcolumn = true,
  _extmark_signs = true,
  on_attach = vim.schedule_wrap(function(bufnr)
    vim.api.nvim_create_autocmd("CursorHold", {
      buffer = bufnr,
      once = true,
      callback = vim.schedule_wrap(function()
        willothy.event.emit("UpdateHeirlineComponents")
        vim.cmd.redrawstatus()
      end),
    })
    vim.api.nvim_exec_autocmds("User", {
      pattern = "GitSignsAttach",
      data = { bufnr = bufnr },
    })
  end),
})
