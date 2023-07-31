require("anyline").setup({
  highlight = "WinSeparator",
  context_highlight = "Function",
  ft_ignore = {
    "NvimTree",
    "TelescopePrompt",
    "Trouble",
    "SidebarNvim",
    "neo-tree",
    "noice",
    "terminal",
  },
})
local au = vim.api.nvim_create_augroup("anyline_au", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "LspAttach", "CursorHold" }, {
  group = au,
  pattern = "*",
  once = true,
  callback = vim.schedule_wrap(function()
    local tab = vim.api.nvim_get_current_tabpage()
    local curwin = vim.api.nvim_get_current_win()
    local visited = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local bufnr = vim.api.nvim_win_get_buf(win)
      vim.api.nvim_win_call(win, function()
        visited[bufnr] = true
        require("anyline.cache").get_cache(bufnr)
        require("anyline.markager").remove_all_marks(bufnr)
        require("anyline.setter").set_marks(bufnr)
        if win == curwin then require("anyline.context").show_context(bufnr) end
      end)
    end
  end),
})
