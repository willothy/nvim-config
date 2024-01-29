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
    -- don't hijack current window
    vim.cmd.vsplit()
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_var(win, "is_oil_win", true)
    require("oil").open(target)
    vim.api.nvim_create_autocmd("BufWinLeave", {
      buffer = vim.api.nvim_get_current_buf(),
      once = true,
      callback = function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, false)
        end
      end,
    })

    -- fixes icons not showing with edgy.nvim
    require("oil.actions").refresh.callback()
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
  local stat = vim.F.ok_or_nil(pcall(uv.fs_stat, bufname))
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
  pcall(vim.api.nvim_clear_autocmds, { group = "FileExplorer" })

  vim.api.nvim_create_autocmd("BufNew", {
    group = vim.api.nvim_create_augroup(
      "willothy.file-browsers",
      { clear = true }
    ),
    pattern = "*",
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
      if n_wins >= 1 then
        return
      end
      n_wins = n_wins + 1
      last_win = last_win or win
    end
  end
  if n_wins == 1 then
    local buf = vim.api.nvim_win_get_buf(last_win)
    M.hijack_dir_buf(buf)
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
    M.browser = M.browsers[options[item]] or M.browser
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
