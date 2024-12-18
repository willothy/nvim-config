-- local function persist(fn)
--   vim.print(debug.getlocal(fn, 1))
-- end
--
-- local Counter = persist(function(Counter)
--   function Counter:inc(delta) end
--
--   function Counter:dec(delta) end
-- end)

-- local sqlite = require("sqlite")
--
-- -- Open the database connection
-- local db = sqlite.new("database.db")
-- db:open()
--
-- -- Initialize the database schema
-- db:execute([[
-- CREATE TABLE IF NOT EXISTS tables (
--     id INTEGER PRIMARY KEY,
--     root BOOLEAN DEFAULT 0
-- );
--
-- CREATE TABLE IF NOT EXISTS key_values (
--     table_id INTEGER,
--     key TEXT,
--     value_type TEXT,
--     value_string TEXT,
--     value_number REAL,
--     value_boolean INTEGER,
--     value_table_id INTEGER,
--     FOREIGN KEY (table_id) REFERENCES tables(id),
--     FOREIGN KEY (value_table_id) REFERENCES tables(id)
-- );
-- ]])
--
-- -- Function to save a Lua table into the database
-- local function save_table(t, is_root, saved_tables)
--   saved_tables = saved_tables or {}
--   if saved_tables[t] then
--     return saved_tables[t]
--   end
--
--   -- Insert the table into the 'tables' table
--   local success, table_id = db:insert("tables", { root = is_root and 1 or 0 })
--   if not success then
--     error("Failed to insert into 'tables'")
--   end
--
--   saved_tables[t] = table_id
--
--   -- Insert key-value pairs into the 'key_values' table
--   for k, v in pairs(t) do
--     local key = tostring(k)
--     local value_type = type(v)
--     local row = {
--       table_id = table_id,
--       key = key,
--       value_type = value_type,
--     }
--
--     if value_type == "string" then
--       row.value_string = v
--     elseif value_type == "number" then
--       row.value_number = v
--     elseif value_type == "boolean" then
--       row.value_boolean = v and 1 or 0
--     elseif value_type == "table" then
--       local child_table_id = save_table(v, false, saved_tables)
--       row.value_table_id = child_table_id
--     else
--       error("Unsupported value type: " .. value_type)
--     end
--
--     local success, _ = db:insert("key_values", row)
--     if not success then
--       error("Failed to insert into 'key_values'")
--     end
--   end
--
--   return table_id
-- end
--
-- -- Function to load a Lua table from the database
-- local function load_table(table_id, loaded_tables)
--   loaded_tables = loaded_tables or {}
--   if loaded_tables[table_id] then
--     return loaded_tables[table_id]
--   end
--
--   local t = {}
--   loaded_tables[table_id] = t
--
--   local rows = db:select("key_values", { where = { table_id = table_id } })
--   for _, row in ipairs(rows) do
--     local key = row.key
--     local value_type = row.value_type
--     local value
--
--     if value_type == "string" then
--       value = row.value_string
--     elseif value_type == "number" then
--       value = row.value_number
--     elseif value_type == "boolean" then
--       value = row.value_boolean == 1
--     elseif value_type == "table" then
--       value = load_table(row.value_table_id, loaded_tables)
--     else
--       error("Unsupported value type: " .. value_type)
--     end
--
--     t[key] = value
--   end
--
--   return t
-- end
--
-- -- Function to perform mark-and-sweep garbage collection
-- local function mark_and_sweep()
--   local marked_tables = {}
--
--   local function mark_table(table_id)
--     if marked_tables[table_id] then
--       return
--     end
--     marked_tables[table_id] = true
--
--     local rows = db:select("key_values", {
--       where = {
--         table_id = table_id,
--         value_type = "table",
--       },
--       keys = { "value_table_id" },
--     })
--
--     for _, row in ipairs(rows) do
--       if row.value_table_id then
--         mark_table(row.value_table_id)
--       end
--     end
--   end
--
--   local root_tables = db:select("tables", {
--     where = { root = 1 },
--     keys = { "id" },
--   })
--
--   for _, row in ipairs(root_tables) do
--     mark_table(row.id)
--   end
--
--   -- Get all table IDs
--   local all_tables = db:select("tables", { keys = { "id" } })
--   for _, row in ipairs(all_tables) do
--     if not marked_tables[row.id] then
--       -- Delete from key_values
--       db:delete("key_values", { table_id = row.id })
--       -- Delete from tables
--       db:delete("tables", { id = row.id })
--     end
--   end
-- end
--
-- -- Function to query nested data
-- local function query_table(table_id, key_path)
--   local current_table_id = table_id
--   for _, key in ipairs(key_path) do
--     local rows = db:select("key_values", {
--       where = {
--         table_id = current_table_id,
--         key = key,
--       },
--     })
--
--     if #rows > 0 then
--       local row = rows[1]
--       if row.value_type == "table" then
--         current_table_id = row.value_table_id
--       else
--         return row
--       end
--     else
--       return nil
--     end
--   end
--   return load_table(current_table_id)
-- end
--
-- -- Example usage
-- local function example_usage()
--   local root_table = {
--     name = "root",
--     child = {
--       name = "child",
--       value = 42,
--       grandchild = {
--         name = "grandchild",
--         value = 100,
--       },
--     },
--   }
--
--   -- Save the root table
--   local root_table_id = save_table(root_table, true)
--
--   -- Load the root table
--   local loaded_root_table = load_table(root_table_id)
--   print("Loaded Root Table Name:", loaded_root_table.name) -- Output: root
--
--   -- Query nested data
--   local result = query_table(root_table_id, { "child", "grandchild", "value" })
--   if result and result.value_number then
--     print("Grandchild Value:", result.value_number) -- Output: 100
--   else
--     print("Value not found")
--   end
--
--   -- Perform garbage collection
--   mark_and_sweep()
-- end
--
-- example_usage()
--
-- -- Close the database connection
-- db:close()

local sqlite = require("sqlite")

-- Open the database connection
local db = sqlite.new("database.db")
db:open()

-- Initialize the database schema
db:execute([[
CREATE TABLE IF NOT EXISTS tables (
    id INTEGER PRIMARY KEY,
    name TEXT UNIQUE,
    root BOOLEAN DEFAULT 0
);

CREATE TABLE IF NOT EXISTS key_values (
    table_id INTEGER,
    key TEXT,
    value_type TEXT,
    value_string TEXT,
    value_number REAL,
    value_boolean INTEGER,
    value_table_id INTEGER,
    FOREIGN KEY (table_id) REFERENCES tables(id),
    FOREIGN KEY (value_table_id) REFERENCES tables(id)
);
]])

-- Mapping tables to IDs and vice versa
local table_to_id = setmetatable({}, { __mode = "k" }) -- Weak keys
local id_to_table = {}

-- Function to get the proxy metatable
local function get_proxy_metatable(table_id)
  local mt = {}

  mt.__metatable = false

  mt.__index = function(self, key)
    local value = rawget(self, key)
    if value ~= nil then
      return value
    end

    -- Try to load the value from the database
    local rows = db:select("key_values", {
      where = {
        table_id = table_id,
        key = tostring(key),
      },
    })

    if #rows > 0 then
      local row = rows[1]
      local value_type = row.value_type

      if value_type == "string" then
        value = row.value_string
      elseif value_type == "number" then
        value = row.value_number
      elseif value_type == "boolean" then
        value = row.value_boolean == 1
      elseif value_type == "table" then
        local nested_table_id = row.value_table_id
        if id_to_table[nested_table_id] then
          value = id_to_table[nested_table_id]
        else
          value = {}
          setmetatable(value, get_proxy_metatable(nested_table_id))
          table_to_id[value] = nested_table_id
          id_to_table[nested_table_id] = value
        end
      else
        error("Unsupported value type: " .. value_type)
      end

      rawset(self, key, value)
      return value
    else
      return nil
    end
  end

  mt.__newindex = function(self, key, value)
    rawset(self, key, value)
    local value_type = type(value)
    local row = {
      table_id = table_id,
      key = tostring(key),
      value_type = value_type,
    }

    if value_type == "string" then
      row.value_string = value
    elseif value_type == "number" then
      row.value_number = value
    elseif value_type == "boolean" then
      row.value_boolean = value and 1 or 0
    elseif value_type == "table" then
      local child_table_id = table_to_id[value]
      if not child_table_id then
        -- Create a new persisted table for the nested table
        local success, id = db:insert("tables", { root = 0 })
        if not success then
          error("Failed to insert into 'tables'")
        end
        child_table_id = id
        table_to_id[value] = child_table_id
        id_to_table[child_table_id] = value
        setmetatable(value, get_proxy_metatable(child_table_id))
      end
      row.value_table_id = child_table_id
    elseif value_type ~= "nil" then
      error("Unsupported value type: " .. value_type)
    end

    -- Delete existing entry for this key, if any
    db:delete("key_values", { table_id = table_id, key = tostring(key) })

    if value_type ~= "nil" then
      -- Insert the new value
      local success, _ = db:insert("key_values", row)
      if not success then
        error("Failed to insert into 'key_values'")
      end
    end
  end

  mt.__pairs = function(self)
    -- Load all keys and values from the database
    local rows = db:select("key_values", { where = { table_id = table_id } })
    for _, row in ipairs(rows) do
      local key = row.key
      if rawget(self, key) == nil then
        mt.__index(self, key)
      end
    end
    return next, self, nil
  end

  return mt
end

-- Function to create a persisted table
local function create_persisted_table(name)
  local t = {}
  local table_id

  -- Insert into 'tables' table
  local success, id = db:insert("tables", { root = 1, name = name })
  if not success then
    error("Failed to insert into 'tables'")
  end
  table_id = id

  table_to_id[t] = table_id
  id_to_table[table_id] = t

  local mt = get_proxy_metatable(table_id)
  setmetatable(t, mt)

  return t
end

-- Function to load a persisted table given its table_id
local function load_persisted_table(table_id)
  if id_to_table[table_id] then
    return id_to_table[table_id]
  end

  local t = {}
  setmetatable(t, get_proxy_metatable(table_id))
  id_to_table[table_id] = t
  table_to_id[t] = table_id
  return t
end

-- Function to get a root table by name
local function get_root_table(name)
  local rows = db:select("tables", { where = { name = name, root = 1 } })
  if #rows > 0 then
    local table_id = rows[1].id
    return load_persisted_table(table_id)
  else
    return nil
  end
end

-- Function to perform mark-and-sweep garbage collection
local function mark_and_sweep()
  local marked_tables = {}

  local function mark_table(table_id)
    if marked_tables[table_id] then
      return
    end
    marked_tables[table_id] = true

    local rows = db:select("key_values", {
      where = {
        table_id = table_id,
        value_type = "table",
      },
      keys = { "value_table_id" },
    })

    for _, row in ipairs(rows) do
      if row.value_table_id then
        mark_table(row.value_table_id)
      end
    end
  end

  local root_tables = db:select("tables", {
    where = { root = 1 },
    keys = { "id" },
  })

  for _, row in ipairs(root_tables) do
    mark_table(row.id)
  end

  -- Get all table IDs
  local all_tables = db:select("tables", { keys = { "id" } })
  for _, row in ipairs(all_tables) do
    if not marked_tables[row.id] then
      -- Delete from key_values
      db:delete("key_values", { table_id = row.id })
      -- Delete from tables
      db:delete("tables", { id = row.id })
      -- Remove from id_to_table
      id_to_table[row.id] = nil
    end
  end
end

-- Function to query nested data
local function query_table(t, key_path)
  local current_table = t
  for _, key in ipairs(key_path) do
    if type(current_table) ~= "table" then
      return nil
    end
    current_table = current_table[key]
  end
  return current_table
end

-- Example usage
local function example_usage()
  -- Create or load the root table
  local root_table = get_root_table("root_table")
  if not root_table then
    root_table = create_persisted_table("root_table")
  end

  -- -- Modify the table
  -- root_table.name = "root"
  -- root_table.child = {}
  -- root_table.child.value = 42
  -- root_table.child.grandchild = { value = 100 }

  -- Access the table
  vim.print("Loaded Root Table Name:", root_table.name) -- Output: root
  vim.print("Loaded Root Table Child:", root_table.child.value) -- Output: root

  -- Query nested data
  local grandchild_value =
    query_table(root_table, { "child", "grandchild", "value" })
  vim.print("Grandchild Value:", grandchild_value) -- Output: 100

  -- Perform garbage collection
  -- mark_and_sweep()
end

example_usage()

-- Close the database connection
db:close()
