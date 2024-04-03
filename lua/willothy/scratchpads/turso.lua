local _url = vim.env.TURSO_URL
local _token = vim.env.TURSO_TOKEN

---@private
---@class LibSQL.RawDatabase: userdata
---@field execute fun(self: LibSQL.RawDatabase, stmt: string)

---@alias LibSQL.Schema table<string, LibSQL.ColumnSchema[]>

---@class LibSQL.ColumnSchema
---@field name string
---@field type string
---@field nullable boolean?
---@field default string?
---@field primary boolean?
---@field autoincrement boolean?

---@class LibSQL.Connection
---@field db LibSQL.Database
---@field private conn LibSQL.RawDatabase
local Connection = {}
Connection.__index = Connection

---@param stmt string
function Connection:execute(stmt)
  return self.conn:execute(stmt)
end

---@class LibSQL.Database
---@field url string
---@field schema LibSQL.Schema
---@field initializers table<string, string>
local Database = {}
Database.__index = Database

---@param url string
---@param schema LibSQL.Schema
---@return LibSQL.Database
function Database.new(url, schema)
  local self = {}

  -- TODO: Validate URL and schema
  self.url = url
  self.schema = schema

  self.initializers = {}

  for name, columns in pairs(schema) do
    local columns_sql = {}
    for _, column in ipairs(columns) do
      local segments = { column.name .. " " .. column.type }
      if column.nullable == false then
        table.insert(segments, "NOT NULL")
      end
      if column.default then
        table.insert(segments, "DEFAULT " .. column.default)
      end
      if column.primary then
        table.insert(segments, "PRIMARY KEY")
      end
      if column.autoincrement then
        table.insert(segments, "AUTOINCREMENT")
      end
      local column_sql = table.concat(segments, " ")
      table.insert(columns_sql, column_sql)
    end

    self.initializers[name] = string.format(
      [[CREATE TABLE IF NOT EXISTS %s ( %s );]],
      name,
      table.concat(columns_sql, ", ")
    )
  end

  return setmetatable(self, Database)
end

---@async
---@param token string
---@return LibSQL.Connection?, string?
function Database:connect(token)
  local lib = require("sidecar")

  local ok, raw = lib.connect(self.url, token)
  if not ok then
    return nil, raw
  end

  local obj = {}

  obj.conn = raw --[[@as LibSQL.RawDatabase]]
  obj.db = self

  return setmetatable(obj, Connection), nil
end

---@param table_name string
---@return LibSQL.ColumnSchema[]
function Database:columns(table_name)
  return self.schema[table_name]
end

---@class LibSQL.Table
---@field name string
---@field private conn LibSQL.Connection
local Table = {}
Table.__index = Table

---@param conn LibSQL.Connection
---@param name string
function Table.new(conn, name)
  local self = {}
  self.conn = conn
  self.name = name
  return setmetatable(self, Table)
end

---@return LibSQL.ColumnSchema[]
function Table:columns()
  return self.conn.db:columns(self.name)
end

function Table:insert(values)
  local keys_sql, values_sql = unpack(vim
    .iter(self:columns())
    :map(function(column)
      local value = values[column.name]
      if value then
        if type(value) == "string" then
          value = "'" .. value .. "'"
        elseif type(value) == "number" then
          value = tostring(value)
        end
        ---@diagnostic disable-next-line: redundant-return-value
        return column.name, value
      end
    end)
    :enumerate()
    :fold({
      keys = "",
      values = "",
    }, function(acc, i, key, val)
      if i > 1 then
        acc.keys = acc.keys .. ", "
        acc.values = acc.values .. ", "
      end

      acc.keys = acc.keys .. key
      acc.values = acc.values .. val

      return acc
    end))

  local sql = string.format(
    [[INSERT INTO %s (%s) VALUES (%s);]],
    self.name,
    keys_sql,
    values_sql
  )

  self.conn:execute(sql)
end

---@class LibSQL.Statement
local Statement = {}
Statement.__index = Statement

---@param sql string
function Statement.parse(sql)
  local self = {}

  local placeholders = {}
  self.placeholders = placeholders

  for match in sql:gmatch("%?(%w+)") do
    table.insert(placeholders, match)
  end

  return setmetatable(self, Statement)
end

-- vim.print(Statement.parse("SELECT * FROM foo WHERE id = ?id AND name = ?name"))

-- vim.print(Database.new(_url, {
--   scratchpad = {
--     {
--       name = "id",
--       type = "INT",
--       primary = true,
--       autoincrement = true,
--     },
--     {
--       name = "content",
--       type = "TEXT",
--     },
--   },
-- }))

-- local nio = require("nio")
--
-- nio.run(function()
--   local err
--
--   local db
--   db, err = Database.connect(_url, _token)
--   if not db then
--     vim.notify("Failed to connect to database: " .. err, vim.log.levels.ERROR)
--     return
--   end
--
--   local co = coroutine.running()
--
--   local resume = function(...)
--     return coroutine.resume(co, ...)
--   end
--   local yield = coroutine.yield
--   ---@async
--   local schedule = function()
--     yield(vim.schedule(resume))
--   end
--
--   schedule()
--   db:execute([[
--     CREATE TABLE IF NOT EXISTS scratchpad (
--       id INT PRIMARY KEY AUTOINCREMENT,
--       content TEXT
--     );
--   ]])
--   schedule()
--   vim.print("Created table scratchpad")
--
--   local value = yield(vim.ui.input(
--     {
--       prompt = "> ",
--     },
--     vim.schedule_wrap(function(input)
--       if input == nil or input == "" then
--         return
--       end
--
--       resume(input)
--     end)
--   ))
--
--   vim.print("Got value: " .. value)
--
--   db:execute(([[
--     INSERT INTO scratchpad (content) VALUES ('%s')
--   ]]):format(value))
--   schedule()
--   vim.print("Inserted content into scratchpad")
--   -- local res = db:execute("DROP TABLE IF EXISTS scratchpad")
--   -- vim.print("Dropped table scratchpad: " .. res)
-- end)
