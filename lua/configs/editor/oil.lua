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
vim.api.nvim_create_autocmd("BufWinLeave", {
  pattern = "oil://*",
  callback = function()
    if require("oil.util").is_oil_bufnr(vim.api.nvim_get_current_buf()) then
      return
    end
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
    -- buflisted = false,
  },
  keymaps = {
    ["<C-s>"] = "actions.select_split",
    ["<C-v>"] = "actions.select_vsplit",
    ["<C-h>"] = false,
    ["<C-l>"] = false,
    ["<C-/>"] = "actions.refresh",
    ["q"] = {
      callback = function()
        local win = vim.api.nvim_get_current_win()
        oil.close()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, false)
        end
      end,
    },
    ["l"] = {
      callback = function()
        local win = vim.api.nvim_get_current_win()
        local entry = oil.get_cursor_entry()
        local vertical, split, tgt_win
        if entry.type == "file" then
          tgt_win = require("flatten.core").smart_open()
          if not tgt_win then
            vertical = true
            split = "belowright"
          end
        end
        oil.select({
          vertical = vertical,
          split = split,
          win = tgt_win,
          close = false,
        }, function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_set_current_win(win)
          end
        end)
      end,
    },
    ["h"] = "actions.parent",
    ["<CR>"] = {
      callback = function()
        local win = vim.api.nvim_get_current_win()
        oil.select({
          vertical = true,
          split = "belowright",
          close = true,
        }, function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, false)
          end
        end)
      end,
    },
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
