local data_dir = vim.fn.stdpath("data")--[[@as string]]
local db_path = vim.fs.joinpath(data_dir, "/databases/willothy.db")

local sqlite = require("sqlite.db")

local db = sqlite({
  uri = db_path,
  opts = {},
}) --[[@as sqlite_db]]

local M = {}

local deserializers = setmetatable({
  string = function(s)
    return s
  end,
  number = function(s)
    return tonumber(vim.base64.decode(s))
  end,
  table = function(s)
    return vim.json.decode(s, {
      luanil = {
        object = true,
        array = true,
      },
    })
  end,
}, {
  __index = function(_, k)
    error(string.format("Unsupported type %s", k))
  end,
})

local serializers = setmetatable({
  string = function(s)
    return s
  end,
  number = function(num)
    return vim.base64.encode(tostring(num))
  end,
  table = function(tbl)
    return vim.json.encode(tbl)
  end,
}, {
  __index = function(_, k)
    error(string.format("Unsupported type %s", k))
  end,
})

local function serialize(value)
  local t = type(value)
  return serializers[t](value), t
end

local function deserialize(str, type)
  return deserializers[type](str)
end

function M.kv_set(key, value, ns)
  if type(key) ~= "string" then
    error("expected string key")
  end
  ns = ns or "__GLOBAL__"
  local ser, ty = serialize(value)
  if
    not db:update("willothy_kv", {
      where = { key = key },
      set = {
        value = ser,
        ltype = ty,
        namespace = ns,
      },
    })
  then
    db:insert("willothy_kv", {
      key = key,
      value = value,
      namespace = ns,
    })
  end
end

function M.kv_get(key, ns)
  if type(key) ~= "string" then
    error("expected string key")
  end
  ns = ns or "__GLOBAL__"
  local res = db:select("willothy_kv", {
    where = {
      key = key,
      namespace = ns,
    },
  })[1]

  if res then
    return deserialize(res.value, res.ltype)
  end
end

function M.kv_del(key, ns)
  if type(key) ~= "string" then
    error("expected string key")
  end
  ns = ns or "__GLOBAL__"
  db:delete("willothy_kv", {
    where = {
      key = key,
      namespace = ns,
    },
  })
end

function M.kv_list(ns)
  ns = ns or "__GLOBAL__"
  return db:select("willothy_kv", {
    where = {
      namespace = ns,
    },
  })
end

function M.kv_update(key, ns, f)
  local val = M.kv_get(key, ns)

  local res = f(val)

  M.kv_set(key, res, ns)
end

function M.kv_init()
  db:open(db_path)
  db:execute([[
    CREATE TABLE if not exists willothy_kv (
      key       text not null,
      namespace text not null,
      value     text,
      ltype     text,
      primary key (key, namespace)
    );
  ]])
  db:execute(
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_kv_key ON willothy_kv(key, namespace)"
  )
end

function M.persist(name, impl)
  local ns = string.format("objects_%s", string.gsub(name, "%W", "_"))

  return setmetatable(impl, {
    __index = function(_self, k)
      return M.kv_get(k, ns)
    end,
    __newindex = function(_self, k, v)
      M.kv_set(k, v, ns)
    end,
  })
end

M.kv_init()

M.kv_set("nvim-opened", tonumber(M.kv_get("nvim-opened") or 0) + 1)

return M
