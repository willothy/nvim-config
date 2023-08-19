require("anyline").setup({
  highlight = "IndentScope",
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
  -- animation stuff / fine tuning
  animation = "from_cursor", -- 'from_cursor' | 'to_cursor' | 'top_down' | 'bottom_up' | 'none'
  debounce_time = 40, -- how responsive to make to make the cursor movements (in ms, very low debounce time is kinda janky at the moment)
  fps = 60, -- changes how many steps are used to transition from one color to another
  fade_duration = 300, -- color fade speed (only used when lines_per_second is 0)
  length_acceleration = 0.04, -- increase animation speed depending on how long the context is

  lines_per_second = 80, -- how many lines/seconds to show
  trail_length = 20, -- how long the trail / fade transition should be

  -- other stuff
  priority = 19, -- extmark priority
  priority_context = 20,
  max_lines = 1000,
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
        if win == curwin then
          require("anyline.context").show_context(bufnr)
        end
      end)
    end
  end),
})
