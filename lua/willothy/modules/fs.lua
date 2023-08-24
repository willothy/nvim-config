local M = {}

M.browsers = {
  telescope = function(target)
    require("telescope").extensions.file_browser.file_browser({ cwd = target })
  end,
  mini = function(target)
    require("mini.files").open(target)
  end,
  oil = function(target)
    require("oil").open(target)
  end,
}

M.browser = M.browsers.telescope

function M.hijack_netrw()
  local netrw_bufname

  pcall(vim.api.nvim_clear_autocmds, { group = "FileExplorer" })
  vim.api.nvim_create_autocmd("BufNew", {
    group = vim.api.nvim_create_augroup(
      "willothy.file-browsers",
      { clear = true }
    ),
    pattern = "*",
    callback = function()
      vim.schedule(function()
        if vim.bo[0].filetype == "netrw" then
          return
        end
        local bufname = vim.api.nvim_buf_get_name(0)
        if vim.fn.isdirectory(bufname) == 0 then
          _, netrw_bufname = pcall(vim.fn.expand, "#:p:h")
          return
        end

        -- prevents reopening of file-browser if exiting without selecting a file
        if netrw_bufname == bufname then
          netrw_bufname = nil
          return
        else
          netrw_bufname = bufname
        end

        local bufnr = vim.api.nvim_get_current_buf()
        vim.api.nvim_set_option_value("bufhidden", "wipe", {
          buf = bufnr,
        })

        M.browse(vim.fn.expand("%:p:h"))

        -- ensure no buffers remain with the directory name
        require("bufdelete").bufwipeout(bufnr)
      end)
    end,
    desc = "telescope-file-browser.nvim replacement for netrw",
  })
end

function M.set_browser()
  local options = vim
    .iter(M.browsers)
    :map(function(name)
      return name
    end)
    :totable()
  vim.ui.select(options, {
    prompt = "Browsers",
  }, function(item)
    M.browser = M.browsers[item] or M.browser
  end)
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
