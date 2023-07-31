local resession = require("resession")

resession.setup({
  extensions = {
    scope = {
      enable_in_tab = true,
    },
  },
  autosave = {
    enabled = true,
    interval = 300,
    notify = false,
  },
  tab_buf_filter = function(tabpage, bufnr)
    return vim.startswith(
      vim.api.nvim_buf_get_name(bufnr),
      vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(tabpage))
    )
  end,
  buf_filter = function(bufnr)
    local filetype = vim.bo[bufnr].filetype
    if
      filetype == "gitcommit"
      or filetype == "gitrebase"
      or vim.bo[bufnr].bufhidden == "wipe"
    then
      return false
    end
    local buftype = vim.bo[bufnr].buftype
    if buftype == "help" then return true end
    if buftype ~= "" and buftype ~= "acwrite" then return false end
    if vim.api.nvim_buf_get_name(bufnr) == "" then return false end
    return vim.bo[bufnr].buflisted
  end,
})

-- Only load the session if nvim was started with no args
if vim.fn.argc(-1) == 0 then
  -- Save these to a different directory, so our manual sessions don't get polluted
  resession.load(
    vim.fn.getcwd(),
    { dir = "dirsession", silence_errors = true }
  )
end
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    resession.save("last", { notify = false })
    vim.iter(vim.api.nvim_list_tabpages()):each(function(tab)
      local win = vim.api.nvim_tabpage_get_win(tab)
      vim.api.nvim_win_call(win, function()
        local cwd = vim.fn.getcwd(-1)
        resession.save_tab(cwd, { dir = "dirsession", notify = false })
      end)
    end)
  end,
})
