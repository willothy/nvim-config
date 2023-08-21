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

starter.setup({
  evaluate_single = true,
  autoopen = false,
  items = items,

  header = function()
    local stats = require("lazy").stats()
    return "Startup in " .. string.format("%.2f", stats.startuptime) .. "ms"
  end,

  footer = function()
    local stats = require("lazy").stats()
    return " Loaded " .. stats.loaded .. " / " .. stats.count
  end,

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

  if
    vim
      .iter(vim.api.nvim_list_bufs())
      :filter(function(buf_id)
        return vim.bo[buf_id].buflisted
      end)
      :next()
  then
    return true
  end

  if vim.fn.argc() > 0 then
    return true
  end

  return false
end

if not is_something_shown() then
  require("mini.starter").open()
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyLoad",
    callback = function()
      require("mini.starter").refresh()
    end,
  })
end
