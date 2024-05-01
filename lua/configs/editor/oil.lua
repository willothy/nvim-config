local Utils = require("oil.util")
local oil = require("oil")

oil.winbar = function()
  if vim.api.nvim_win_get_config(0).relative ~= "" then
    vim.wo[0].winbar = ""
    return ""
  end
  local path = oil.get_current_dir():gsub(vim.env.HOME, "~"):gsub("/$", "")
  local width = vim.api.nvim_win_get_width(0)
  local limit = width - 2
  if string.len(path) > limit then
    path = willothy.fs.incremental_shorten(path, limit)
  end
  return path .. "/"
end

vim.api.nvim_create_autocmd("WinNew", {
  pattern = "oil://*",
  callback = function()
    -- ensure the window is the one that was current
    -- when the autocmd was executed, since the rest
    -- of the callback will executed later.
    local win = vim.api.nvim_get_current_win()
    vim.schedule(function()
      if
        vim.api.nvim_win_is_valid(win)
        and require("oil.util").is_oil_bufnr(vim.api.nvim_win_get_buf(win))
      then
        vim.w[win].oil_opened = true
      end
    end)
  end,
})

-- Auto-confirm changes on exit.
-- If the user cancels the save, discard all changes.
--
-- This is more like the behavior of mini.files, which I like.
vim.api.nvim_create_autocmd("BufHidden", {
  pattern = "oil://*",
  callback = function(ev)
    if vim.v.exiting ~= vim.NIL then
      return
    end
    local buf = ev.buf
    if
      Utils.is_oil_bufnr(buf)
      and vim.iter(vim.api.nvim_list_wins()):any(function(win)
        return Utils.is_oil_bufnr(vim.api.nvim_win_get_buf(win))
      end)
    then
      vim.schedule(function()
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
      end)
    end
  end,
})

oil.setup({
  default_file_explorer = false,
  buf_options = {},
  keymaps = {
    ["<C-s>"] = "actions.select_split",
    ["<C-v>"] = {
      callback = function()
        oil.select({
          vertical = true,
          split = "belowright",
        })
      end,
    },
    ["<C-h>"] = false,
    ["<C-l>"] = false,
    ["<C-/>"] = "actions.refresh",
    ["q"] = {
      callback = function()
        local win = vim.api.nvim_get_current_win()
        local alt = vim.api.nvim_win_call(win, function()
          return vim.fn.winnr("#")
        end)

        oil.close()

        if
          vim.api.nvim_win_is_valid(win)
          and vim.w[win].oil_opened
          and alt ~= 0
        then
          vim.api.nvim_win_close(win, false)
        end
      end,
    },
    ["L"] = {
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
    ["H"] = "actions.parent",
    ["<CR>"] = "actions.select",
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
    border = "single",
    win_options = {},
  },
})
