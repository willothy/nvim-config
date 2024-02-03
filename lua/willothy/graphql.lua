local Http = {}

function Http.get(url, opts, callback)
  return willothy.net.http("GET", url, opts, callback)
end

function Http.post(url, opts, callback)
  return willothy.net.http("POST", url, opts, callback)
end

Http.async = {}

local nio = require("nio")

Http.async.get = nio.wrap(Http.get, 3)
Http.async.post = nio.wrap(Http.post, 3)

---@alias Willothy.HTTP.Version "HTTP/0.9" | "HTTP/1.0" | "HTTP/1.1" | "HTTP/2.0" | "HTTP/3.0"

---@class Willothy.HTTP.Request
---@field url string
---@field query? table<string, string>
---@field body? string | table
---@field headers? table<string, string>
---@field json? boolean
---@field version? Willothy.HTTP.Version

---The body of an HTTP response.
---@alias Willothy.HTTP.Response table | string

---@class Willothy.GraphQL.ClientConfig
---@field scheme string
---@field hostname string
---@field endpoint string
---@field headers table|fun(client: Willothy.GraphQL.Client): table
---@field data? table

---@class Willothy.GraphQL.ClientConfigOpts: Willothy.GraphQL.ClientConfig
---@field scheme? string
---@field hostname string
---@field endpoint? string
---@field headers table|fun(client: Willothy.GraphQL.Client): table
---@field data? table

---@alias Willothy.GraphQL.Query
---       | async fun(variables: table): boolean, Willothy.HTTP.Response

---@class Willothy.GraphQL.Client
---@field url string
---@field config Willothy.GraphQL.ClientConfig
---@field private _generator? fun(query: string): Willothy.GraphQL.Query Cached query generator
---@field private _queries table<string, Willothy.GraphQL.Query>
---@field private _cache table<string, Willothy.HTTP.Response> Cached query results
local Client = {}

---@param opts Willothy.GraphQL.ClientConfigOpts
function Client:new(opts)
  local o = {
    _queries = {},
    _cache = setmetatable({}, {
      -- Weak table to invalidate results of cached queries on GC cycle
      __mode = "v",
    }),
  }

  vim.validate({
    scheme = { opts.scheme, "string", true }, -- defaults to "https"
    hostname = { opts.hostname, "string" },
    endpoint = { opts.endpoint, "string", true }, -- defaults to "/"
    headers = { opts.headers, { "table", "function" } },
  })

  o.config = opts

  o.config = vim.tbl_deep_extend("keep", o.config, {
    scheme = "https",
    endpoint = "/",
  })

  o.url = string.format(
    "%s://%s%s",
    o.config.scheme,
    o.config.hostname,
    o.config.endpoint
  )

  self.__index = self

  return setmetatable(o, self)
end

---Adds a named query fn to the client.
---
---If the query is a string, it will be "compiled" into a function which
---can be executed with the given variables.
---Otherwise, the query is assumed to be a function which can be executed,
---created from the `Client:generator()` method.
---@param name string
---@param query Willothy.GraphQL.Query | string
---@return Willothy.GraphQL.Client
function Client:add(name, query)
  if type(query) == "string" then
    local query_str = query
    query = function(variables)
      return self:request(query_str, variables)
    end
  end
  self._queries[name] = query
  return self
end

---@return string
local function concat_hash(...)
  return table.concat({ ... }, "%%", 1)
end

---Adds a named query fn to the client, and automatically caches its result.
---
---If the query is a string, it will be "compiled" into a function which
---can be executed with the given variables.
---Otherwise, the query is assumed to be a function which can be executed,
---created from the `Client:generator()` method.
---@param name string
---@param query Willothy.GraphQL.Query | string
---@return Willothy.GraphQL.Client
function Client:add_cached(name, query)
  if type(query) == "string" then
    local query_str = query
    query = function(variables)
      return self:request(query_str, variables)
    end
  end

  self._queries[name] = function(...)
    local key = concat_hash(name, ...)
    local cached = self._cache[key]
    if cached then
      return true, cached
    end
    local ok, res = query(...)
    if ok then
      self._cache[key] = res
    end
    return ok, res
  end

  return self
end

---@async
---Executes a named query with the given variables.
---@param query_name string
---@param variables? table
---@return boolean, Willothy.HTTP.Response
function Client:query(query_name, variables)
  variables = variables or {}
  local query_fn = self._queries[query_name]
  if not query_fn then
    error(string.format("Query '%s' does not exist", query_name))
  end
  return query_fn(variables)
end

---@return table<string, string>
function Client:headers()
  if type(self.config.headers) == "function" then
    return self.config.headers(self)
  end
  return self.config.headers --[[@as table<string, string>]]
end

---@async
---@param query string
---@param variables table
---@return boolean, Willothy.HTTP.Response
function Client:request(query, variables)
  return Http.async.post(self.url, {
    headers = self:headers(),
    body = vim.json.encode({
      query = query,
      variables = variables,
    }),
  })
end

---@return fun(query: string): Willothy.GraphQL.Query
function Client:generator()
  if self._generator then
    return self._generator
  end
  local generator = function(query)
    return function(variables)
      return self:request(query, variables)
    end
  end
  self._generator = generator
  return generator
end

return {
  Client = Client,
}
