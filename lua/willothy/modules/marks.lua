---@class Mark
---@field file string
---@field name string
---@field line integer
---@field col integer

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
    name = { "text", required = true },
    line = { "number", required = true },
    col = { "number", required = true },
    global = { "boolean", required = true },
  },
  opts = {},
})

local marks = db.marks

---@param file string
---@param name string
---@param line integer
---@param col integer?
---@param global boolean?
function marks:set(file, name, line, col, global)
  file = vim.fs.normalize(file)
  if vim.fn.strcharlen(name) ~= 1 then
    vim.api.nvim_err_writeln("Mark name must be a single character")
    return
  end
  local mark = self:where({ name = name, file = file })
  if mark then
    self:update({
      where = { name = name, file = file },
      set = { line = line, col = col or 0 },
    })
  else
    self:insert({
      name = name,
      file = file,
      line = line,
      col = col or 0,
      global = global or false,
    })
  end
end

---@param file string
---@param name string?
function marks:delete(file, name)
  if vim.fn.strcharlen(name) ~= 1 then
    vim.api.nvim_err_writeln("Mark name must be a single character")
    return
  end
  file = vim.fs.normalize(file)
  self:remove({ file = file, name = name })
end

function marks:clear()
  self:remove()
end

return marks
