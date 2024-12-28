local M = {}

---@type table<string, fun(target: string?)>
M.browsers = {
  telescope = function(target)
    require("telescope").extensions.file_browser.file_browser({
      cwd = target,
      display_stat = {
        size = true,
        date = true,
      },
    })
  end,
  mini = function(target)
    require("mini.files").open(target)
  end,
  oil = function(target)
    -- TODO: maybe upstream this into Oil? I think it would be nice to have.
    -- require("oil")
    require("oil").open(target)

    -- if
    --   vim.bo.filetype == "oil"
    --   and require("plenary.path"):new(target):absolute()
    --     == require("oil").get_current_dir():gsub("/$", "")
    -- then
    --   return
    -- end
    -- vim.cmd.vsplit()
    -- require("oil").open(target)
    -- local win = vim.api.nvim_get_current_win()
    -- local buf = vim.api.nvim_get_current_buf()
    --
    -- local winhl = vim.api.nvim_get_option_value("winhighlight", {
    --   win = win,
    -- })
    -- winhl = winhl:gsub("NormalNC:%w+,?", "")
    -- if winhl == "" then
    --   winhl = "NormalNC:Normal"
    -- else
    --   winhl = winhl .. ",NormalNC:Normal"
    -- end
    -- vim.api.nvim_set_option_value("winhighlight", winhl, {
    --   win = win,
    -- })
    --
    -- vim.api.nvim_create_autocmd("BufLeave", {
    --   buffer = buf,
    --   callback = function()
    --     if
    --       vim.api.nvim_win_is_valid(win)
    --       -- only close the window if the buffer has changed
    --       -- basically we treat this autocmd as "BufWinLeave" but for
    --       -- all windows containing oil buffers, not just the last one.
    --       and vim.api.nvim_win_get_buf(win) ~= buf
    --     then
    --       vim.api.nvim_win_close(win, true)
    --     else
    --       -- delete the buffer immediately if its no longer displayed
    --       -- fixes icons not showing with edgy.nvim
    --       vim.schedule(function()
    --         if
    --           vim.api.nvim_buf_is_valid(buf)
    --           and #vim.fn.getbufinfo(buf)[1].windows == 0
    --         then
    --           vim.api.nvim_buf_delete(buf, {})
    --           if
    --             vim.api.nvim_win_is_valid(win)
    --             and not require("oil.util").is_oil_bufnr(
    --               vim.api.nvim_win_get_buf(win)
    --             )
    --           then
    --             vim.api.nvim_win_close(win, true)
    --           end
    --         end
    --       end)
    --     end
    --   end,
    -- })
  end,
}

---@type fun(target: string?)
M.browser = M.browsers.oil

---@param buf integer
function M.hijack_dir_buf(buf)
  if vim.bo[buf].buftype ~= "" then
    return
  end

  local bufnr = buf
  local uv = vim.uv or vim.loop
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then
    return
  end
  local stat = uv.fs_stat(bufname)
  if not stat or stat.type ~= "directory" then
    return
  end

  if bufnr then
    -- ensure no buffers remain with the directory name
    require("bufdelete").bufdelete(bufnr)
  end

  vim.schedule(function()
    M.browse(bufname)
  end)
end

function M.hijack_netrw()
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1
  if vim.fn.exists("#FileExplorer") == 1 then
    vim.api.nvim_clear_autocmds({ group = "FileExplorer" })
  end

  vim.api.nvim_create_autocmd("BufAdd", {
    group = vim.api.nvim_create_augroup("ExplHijackDirBuf", { clear = true }),
    pattern = "*",
    nested = true,
    callback = function(ev)
      M.hijack_dir_buf(ev.buf)
    end,
    desc = "Hijack netrw with switchable file browser",
  })

  local argc = vim.fn.argc()
  if argc ~= 1 then
    return
  end

  local last_win
  local n_wins = 0
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).zindex == nil then
      -- TODO: do I only want to hijack buffers when there's one window?
      if n_wins >= 1 then
        return
      end
      n_wins = n_wins + 1
      last_win = last_win or win
    end
  end
  if n_wins == 1 then
    M.hijack_dir_buf(vim.api.nvim_win_get_buf(last_win))
  end
end

function M.set_browser()
  local a = require("nio")
  a.run(function()
    local options = {}
    for browser in pairs(M.browsers) do
      table.insert(options, browser)
    end
    local item = a.ui.select(options, {
      prompt = "Browsers",
    })
    if not item then
      return
    end
    M.browser = M.browsers[item] or M.browser
  end)
end

---@param target? string | string[] | fun():string
---@param browser? string
function M.browse(target, browser)
  if target == nil then
    target = vim.fn.getcwd()
  elseif type(target) == "function" then
    target = target()
  elseif type(target) == "table" then
    target = table.concat(target, "/")
  end
  local browse
  if browser then
    browse = M.browsers[browser] or M.browser
  else
    browse = M.browser
  end
  browse(target)
end

---@param path string
---@param length integer
---@param hint string?
function M.incremental_shorten(path, length, hint)
  local sep = require("plenary.path").path.sep
  local segments = vim.fn.split(path, sep)
  local len = #segments
  local strlen = string.len(path)
  while strlen > length do
    local all_short = true
    for i = 1, len do
      local l = vim.fn.strcharlen(segments[i])
      if l > 1 then
        if hint then
          if vim.fn.strcharpart(segments[i], l - 1, 1) == hint then
            segments[i] = vim.fn.strcharpart(segments[i], 0, l - 2) .. hint
          else
            segments[i] = vim.fn.strcharpart(segments[i], 0, l - 1) .. hint
            strlen = strlen + 1
          end
        else
          segments[i] = vim.fn.strcharpart(segments[i], 0, l - 1)
        end
        strlen = strlen - 1
        all_short = false
      end
      if strlen <= length then
        break
      end
    end
    if all_short then
      -- the path cannot be shortened any further
      -- if we don't break here, we'll be stuck in an infinite loop
      break
    end
  end
  return table.concat(segments, sep)
end

---@param path string
---@return boolean
function M.is_root(path)
  if string.sub(package["config"], 1, 1) == "\\" then
    return string.match(path, "^[A-Z]:\\?$")
  end
  return path == "/"
end

function M.project_root()
  return require("lspconfig.util").find_git_ancestor(vim.fn.getcwd(-1))
end

---@param dir string?
---@return string?
function M.crate_root(dir)
  local file = vim.fs.find("Cargo.toml", {
    upward = true,
    type = "directory",
    path = dir or vim.fn.getcwd(-1),
  })[1]
  if not file then
    return
  end
  return vim.fs.dirname(file)
end

function M.parent_crate()
  local root = M.crate_root()
  if root == nil then
    return
  end
  local parent = M.crate_root(root .. "../")
  if parent == nil then
    vim.notify("No parent crate found")
  end
  return parent
end

function M.open_project_toml()
  local root = M.crate_root()
  if root == nil then
    return
  end
  vim.api.nvim_command("edit " .. string.format("%s", root) .. "/Cargo.toml")
end

return M
