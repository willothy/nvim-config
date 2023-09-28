---The idea behind this module is to provide a way to mark files in a project.
---It's pretty much a clone of Harpoon, but without the terminal stuff and using
---a sqlite database instead of a json file.

---@class Mark
---@field id integer
---@field ord integer
---@field project string
---@field file string

---@class Project
---@field name string
---@field cwd string

---@class MarksTable: sqlite_tbl

---@class ProjectsTable: sqlite_tbl

---@class MarkDatabase: sqlite_db
---@field marks MarksTable
---@field projects ProjectsTable

local sqlite = require("sqlite.db")

---@class Marks
---@field db_path string
---@field private _db MarkDatabase
---@field private _projects ProjectsTable
---@field private _marks MarksTable
local M = {}

M.db_path = vim.fn.stdpath("data") .. "/databases/marks.sqlite3"

function M.ensure_setup()
  if not M._db then
    M.setup()
  end
end

function M.project_root()
  M.ensure_setup()
  local cwd = vim.fn.getcwd(-1)
  if not cwd then
    return
  end
  local root = vim.fs.find({
    ".git",
    "package.json",
    "Cargo.toml",
  }, {
    upward = true,
    stop = vim.uv.os_homedir(),
    path = cwd,
  })[1]
  if not root then
    return
  end
  cwd = vim.fs.dirname(root)
  return cwd
end

function M.list_projects()
  M.ensure_setup()
  ---@diagnostic disable-next-line: missing-fields
  return M._projects:get({})
end

function M.current_project()
  M.ensure_setup()
  local cwd = M.project_root()
  if not cwd then
    return
  end
  local current = M._projects:where({
    cwd = cwd,
  })
  if current then
    return current
  end
  local name = vim.fs.basename(cwd)
  if not name then
    return
  end
  M._projects:insert({
    name = name,
    cwd = cwd,
  })
  return M._projects:where({
    cwd = cwd,
  })
end

function M.list_marks()
  M.ensure_setup()
  local current = M.current_project()
  if not current then
    return
  end
  ---@diagnostic disable-next-line: missing-fields
  return M._marks:get({
    where = { project = current.cwd },
    order_by = { asc = { "ord" } },
  })
end

function M.create_mark(file)
  M.ensure_setup()
  file = file or vim.api.nvim_buf_get_name(0)
  local current = M.current_project()
  if not current then
    return
  end

  local mark = M._marks:where({
    project = current.cwd,
    file = file,
  })

  if mark then
    return mark
  end

  M._marks:insert({
    project = current.cwd,
    file = file,
    ord = #M.list_marks(),
  })
  return M._marks:where({
    project = current.cwd,
    file = file,
  })
end

function M.delete_mark(file)
  M.ensure_setup()
  file = file or vim.api.nvim_buf_get_name(0)
  local current = M.current_project()
  if not current then
    return
  end
  M._marks:remove({
    project = current.cwd,
    file = file,
  })
end

function M.toggle_mark(file)
  M.ensure_setup()
  file = file or vim.api.nvim_buf_get_name(0)
  local current = M.current_project()
  if not current then
    return
  end
  local mark = M._marks:where({
    project = current.cwd,
    file = file,
  })
  if mark then
    M._marks:remove({ id = mark.id })
    return
  end
  M._marks:insert({
    project = current.cwd,
    file = file,
    ord = #M.list_marks(),
  })
end

function M.delete_marks()
  M.ensure_setup()
  local current = M.current_project()
  if not current then
    return
  end
  M._marks:remove({ project = current.cwd })
end

function M.setup(opts)
  opts = opts or {}

  if opts.db_path then
    M.db_path = opts.db_path
  end

  local db_dir = vim.fn.fnamemodify(M.db_path, ":h")
  if db_dir and not vim.loop.fs_stat(db_dir) then
    vim.fn.mkdir(db_dir, "p")
  end

  local db = sqlite({
    uri = M.db_path,
    marks = {
      id = { "integer", primary = true },
      ord = { "integer", required = true },
      file = { "text", required = true },
      project = { "text", required = true, reference = "projects.cwd" },
    },
    projects = {
      cwd = { "text", required = true, primary = true },
      name = { "text", required = true },
    },
    opts = {},
  })

  M._db = db
  M._projects = db.projects
  M._marks = db.marks

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      M._db:close()
    end,
  })
end

return M
