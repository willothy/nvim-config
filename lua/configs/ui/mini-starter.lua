local starter = require("mini.starter")
local items = {
  -- starter.sections.builtin_actions(),
  {
    name = "Projects",
    action = ":Telescope projects",
    section = "Telescope",
  },
  {
    name = "Recent Files",
    action = ":Telescope oldfiles",
    section = "Telescope",
  },
  {
    name = "File Brower",
    action = ":Telescope file_browser",
    section = "Telescope",
  },
  -- starter.sections.recent_files(10, false),
  starter.sections.recent_files(10, true),
  -- Use this if you set up 'mini.sessions'
  -- starter.sections.sessions(9, true),
}

local stats = require("lazy").stats()

starter.setup({
  evaluate_single = true,
  autoopen = false,
  items = items,

  header = "Startup in " .. string.format("%.2f", stats.startuptime) .. "ms",

  footer = " Loaded " .. stats.loaded .. " / " .. stats.count,

  content_hooks = {
    starter.gen_hook.adding_bullet(),
    starter.gen_hook.indexing("all", { "Telescope", "Recent Files" }),
    starter.gen_hook.padding(5, 2),
    starter.gen_hook.aligning("center", "center"),
  },
})

local function is_something_shown()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  if #lines > 1 or (#lines == 1 and lines[1]:len() > 0) then
    return true
  end

  -- - Several buffers are listed (like session with placeholder buffers). That
  --   means unlisted buffers (like from `nvim-tree`) don't affect decision.
  local listed_buffers = vim.tbl_filter(function(buf_id)
    return vim.fn.buflisted(buf_id) == 1
  end, vim.api.nvim_list_bufs())
  if #listed_buffers > 1 then
    return true
  end

  -- - There are files in arguments (like `nvim foo.txt` with new file).
  if vim.fn.argc() > 0 then
    return true
  end

  return false
end

if
  -- vim
  --   .iter(vim.api.nvim_list_bufs())
  --   :filter(function(b)
  --     return vim.api.nvim_buf_is_loaded(b)
  --       and vim.bo.filetype ~= ""
  --       and vim.bo[b].buftype == ""
  --       and vim.bo[b].buflisted == true
  --       and vim.api.nvim_buf_get_name(b) ~= ""
  --   end)
  --   :next() == nil
  not is_something_shown()
then
  require("mini.starter").open()
end
