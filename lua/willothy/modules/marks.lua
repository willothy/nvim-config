---The idea behind this module is to provide a way to mark files in a project.
---It's pretty much a clone of Harpoon, but without the terminal stuff and using
---a sqlite database instead of a json file.
---
--- TODO:
--- - [ ] Write tests
--- - [ ] Add support for project switching
--- - [ ] Add support for global marks
--- - [ ] Add more metadata to marks
--- - [ ] Support relative paths
--- - [ ] Better rendering using Nui
--- - [ ] Devicons
---

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
  file = vim.fs.normalize(file)
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
  file = vim.fs.normalize(file)
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
  file = vim.fs.normalize(file)
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

function M.save_state()
  local buf = M._menu_buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local marks = M.list_marks()
  if not marks then
    return
  end

  local mark_files = vim.iter(marks):fold({}, function(acc, mark)
    acc[mark.file] = mark
    return acc
  end)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
  lines = vim.split(table.concat(lines, "\n"), "\n", { trimempty = true })
  local order = {}
  for i, line in ipairs(lines) do
    local fname = vim.trim(line)
    local mark = mark_files[line]
    if not mark then
      mark = M.create_mark(fname)
      mark_files[line] = mark
    end
    if mark then
      mark.found = true
      order[i] = mark.id
    end
  end
  for i, id in ipairs(order) do
    M._marks:update({
      where = {
        id = id,
      },
      set = {
        ord = i - 1,
      },
    })
  end
  for _, mark in pairs(mark_files) do
    if not mark.found then
      M._marks:remove({ id = mark.id })
    end
  end
end

function M._menu_get_or_create_buf()
  if M._menu_buf and vim.api.nvim_buf_is_valid(M._menu_buf) then
    return M._menu_buf
  end
  local buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(buf, "mark-menu")
  M._menu_buf = buf

  M._menu_buf_options(buf)
  M._menu_buf_keymaps(buf)
  M._menu_buf_autocmd(buf)

  return buf
end

function M._menu_buf_options(buf)
  vim.bo[buf].buflisted = false
  vim.bo[buf].buftype = "acwrite"
  vim.bo[buf].filetype = "marks"
  vim.bo[buf].bufhidden = "delete"
  vim.bo[buf].swapfile = false
  vim.bo[buf].undofile = false
end

function M._menu_buf_keymaps(buf)
  vim.keymap.set("n", "<esc>", M.close_menu, { buffer = buf })

  vim.keymap.set("n", "q", M.close_menu, { buffer = buf })

  vim.keymap.set("n", "<cr>", function()
    local marks = M.list_marks()
    if not marks then
      return
    end
    local cursor = vim.api.nvim_win_get_cursor(0)
    local mark = marks[cursor[1]]
    if not mark then
      mark = M.create_mark(
        vim.fs.normalize(vim.trim(vim.api.nvim_get_current_line()))
      )
      if not mark then
        return
      end
    end
    M.close_menu()
    vim.schedule(function()
      local path = vim.fs.normalize(mark.file)
      local bufnr = vim.uri_to_bufnr("file://" .. path)
      if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        if not vim.api.nvim_buf_is_loaded(bufnr) then
          vim.fn.bufload(bufnr)
        end
        vim.bo[bufnr].buflisted = true
        vim.api.nvim_set_current_buf(bufnr)
      end
    end)
  end, { buffer = buf })
end

function M._menu_buf_autocmd(buf)
  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = buf,
    once = true,
    callback = vim.schedule_wrap(M.close_menu),
  })

  vim.api.nvim_create_autocmd({
    "BufDelete",
    "BufUnload",
    "BufWipeout",
  }, {
    buffer = buf,
    once = true,
    callback = M.save_state,
  })

  vim.api.nvim_create_autocmd({ "BufWriteCmd", "TextChanged" }, {
    buffer = buf,
    callback = M.save_state,
  })
end

function M.close_menu()
  M.save_state()
  if M._menu_win and vim.api.nvim_win_is_valid(M._menu_win) then
    vim.api.nvim_win_close(M._menu_win, true)
  end
  if M._menu_buf and vim.api.nvim_buf_is_valid(M._menu_buf) then
    vim.api.nvim_buf_delete(M._menu_buf, { force = true })
  end
  M._menu_win = nil
  M._menu_buf = nil
end

---@param marks Mark[]
function M._menu_render_lines(marks)
  local lines = vim
    .iter(marks)
    :map(function(mark)
      return mark.file
    end)
    :totable()
  vim.api.nvim_buf_set_lines(M._menu_buf, 0, -1, false, lines)
  vim.bo[M._menu_buf].modified = false
end

function M.menu_is_open()
  return M._menu_win and vim.api.nvim_win_is_valid(M._menu_win)
end

function M._menu_open_win()
  local width = 50
  local height = 10 -- clamp(10, 10, #marks)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "solid",
    title = "Marks",
    title_pos = "center",
  }

  local win = vim.api.nvim_open_win(M._menu_buf, true, win_opts)
  vim.wo[win].relativenumber = false
  vim.wo[win].number = true
  M._menu_win = win
end

function M.toggle_menu()
  M.ensure_setup()
  if M.menu_is_open() then
    return M.close_menu()
  end

  local marks = M.list_marks()
  if not marks then
    return
  end

  M._menu_get_or_create_buf()
  M._menu_render_lines(marks)
  M._menu_open_win()
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
