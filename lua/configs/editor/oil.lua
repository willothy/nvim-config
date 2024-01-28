local oil = require("oil")

oil.winbar = function()
  if vim.api.nvim_win_get_config(0).relative ~= "" then
    return "%#NormalFloat#"
  end
  local path = oil.get_current_dir():gsub(vim.env.HOME, "~"):gsub("/$", "")
  local width = vim.api.nvim_win_get_width(0)
  local limit = width - 2
  if string.len(path) > limit then
    local parents = vim.iter(vim.fs.parents(path)):totable()
    local len = #parents + 1
    local max_seg_width = math.floor(limit / (len + 1))
    path = vim.fn.pathshorten(path, math.max(1, max_seg_width))
  end
  return path .. "/"
end

-- Auto-confirm changes on exit.
-- If the user cancels the save, discard all changes.
--
-- This is more like the behavior of mini.files, which I like.
vim.api.nvim_create_autocmd("BufLeave", {
  pattern = "oil://*",
  callback = function()
    oil.save({
      confirm = true,
    }, function(err)
      if err then
        if err == "Canceled" then
          oil.discard_all_changes()
        else
          vim.notify(err, vim.log.levels.WARN, {
            title = "Oil",
          })
        end
      end
    end)
  end,
})

oil.setup({
  default_file_explorer = false,
  buf_options = {
    buflisted = false,
  },
  keymaps = {
    ["<C-s>"] = "actions.select_split",
    ["<C-v>"] = "actions.select_vsplit",
    ["<C-h>"] = false,
    ["<C-l>"] = false,
    ["<C-/>"] = "actions.refresh",
    ["q"] = "actions.close",
    ["l"] = "actions.select",
    ["h"] = "actions.parent",
  },
  win_options = {
    statuscolumn = "",
    signcolumn = "no",
    numberwidth = 1,
    number = false,
    relativenumber = false,
    winbar = "%{%v:lua.require('oil').winbar()%}",
  },
  float = {
    win_options = {},
  },
})
