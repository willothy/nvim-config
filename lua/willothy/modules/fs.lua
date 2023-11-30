local M = {}

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
    require("oil").open(target)
  end,
}

M.browser = M.browsers.telescope

function M.hijack_dir_buf(buf)
  if vim.bo[buf].buftype ~= "" then
    return
  end

  local bufnr = buf
  local uv = vim.uv or vim.loop
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local stat = vim.F.ok_or_nil(pcall(uv.fs_stat, bufname))
  if not stat or stat.type ~= "directory" then
    return
  end

  -- ensure no buffers remain with the directory name
  require("bufdelete").bufdelete(bufnr)

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

  local last_win
  local n_wins = 0
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).zindex == nil then
      n_wins = n_wins + 1
      last_win = last_win or win
    end
  end
  if vim.fn.argc() == 1 and n_wins == 1 then
    local buf = vim.api.nvim_win_get_buf(last_win)
    M.hijack_dir_buf(buf)
  end
end

M.set_browser = function()
  local a = require("micro-async")
  a.void(function()
    local options = {}
    for browser in pairs(M.browsers) do
      table.insert(options, browser)
    end
    local ok, item = a.wrap(vim.ui.select, 3)(options, {
      prompt = "Browsers",
    })
    if not ok or not item then
      return
    end
    M.browser = M.browsers[options[item]] or M.browser
  end)()
end

---@param target string | string[] | nil | fun():string
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

function M.is_root(pathname)
  if string.sub(package["config"], 1, 1) == "\\" then
    return string.match(pathname, "^[A-Z]:\\?$")
  end
  return pathname == "/"
end

function M.project_root()
  return require("lspconfig.util").find_git_ancestor(vim.fn.getcwd(-1))
end

function M.crate_root(dir)
  return vim.fs.find("Cargo.toml", {
    upward = true,
    type = "directory",
    path = dir or vim.fn.getcwd(-1),
  })
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
