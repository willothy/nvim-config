local _url = ""
local _token = ""
-- local libsql = require("libsql")
--
-- local conn = libsql.connect(_url, _token)
--
-- local rows = conn:query("SELECT * FROM scratchpad WHERE id = ?1 OR id = ?2", {
--   14,
--   12,
-- })
--
-- local contents = vim
--   .iter(function()
--     return rows:next()
--   end)
--   :map(function(row)
--     return row:get(1)
--   end)
--   :totable()
--
-- vim.print(contents)

local libsql = require("libsql")

local db = libsql.connect(_url, _token)

db:execute(
  [[
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT
  );
]],
  {}
)

local rows =
  db:query("SELECT * FROM users WHERE name=?1 OR name=?2", { "Alice", "Bob" })

for row in rows do
  for col = 0, row:column_count() - 1 do
    print(
      string.format(
        "%s: %s = %s",
        row:column_name(col),
        row:column_type(col),
        row:get(col)
      )
    )
  end
end
