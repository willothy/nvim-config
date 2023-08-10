local function set_layout(node)
  local ty = node[1]
  if ty == "leaf" then
    local buf = node[2]
    if type(buf) == "string" then
      buf = vim.fn.bufadd(buf)
      vim.api.nvim_buf_set_option(buf, "buflisted", true)
    end
    vim.api.nvim_set_current_buf(buf)
  else
    local winids = {}
    for i in ipairs(node[2]) do
      if i > 1 then
        if ty == "row" then
          vim.cmd("vsplit")
        else
          vim.cmd("split")
        end
      end
      table.insert(winids, 1, vim.api.nvim_get_current_win())
    end
    for i, v in ipairs(node[2]) do
      vim.api.nvim_set_current_win(winids[i])
      set_layout(v)
    end
  end
end

set_layout({
  "row",
  {
    {
      "leaf",
      vim.fn.expand("%"),
    },
    {
      "col",
      {
        {
          "leaf",
          "init.lua",
        },
        {
          "leaf",
          "init.lua",
        },
      },
    },
  },
})
