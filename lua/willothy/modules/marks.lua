---@class Mark
---@field project string
---@field file string
---@field global boolean

---@class MarkTable: sqlite_tbl

---@class MarkDatabase: sqlite_db
---@field marks MarkTable

local sqlite = require("sqlite.db")

local path = (vim.fn.stdpath("data") .. "/databases/marks.sqlite3")

---@type MarkDatabase
local db = sqlite({
  uri = path,
  marks = {
    file = { "text", required = true },
    project = { "text", required = false },
    global = { "boolean", required = true },
  },
  opts = {},
})

local marks = db.marks

---@param file string
---@param project string?
function marks:set(file, project)
  file = vim.fs.normalize(file)
  local mark = self:where({
    project = project,
    file = file,
    global = project == nil,
  })
  if not mark then
    self:insert({
      file = file,
      project = project,
      global = project == nil,
    })
  end
end

---@param project string
---@param file string?
function marks:delete(project, file)
  local query = {
    project = project,
    global = project == nil,
  }
  if file then
    query.file = vim.fs.normalize(file)
  end
  self:remove(query)
end

function marks:clear()
  ---@diagnostic disable-next-line: missing-parameter
  self:remove()
end

return marks
