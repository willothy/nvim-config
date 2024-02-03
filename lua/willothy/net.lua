local M = {}

---@alias HTTP.Method "GET" | "POST" | "PUT" | "DELETE" | "HEAD" | "OPTIONS" | "PATCH" | "TRACE" | "CONNECT"

---@class HTTP.RequestOptions

---@param method HTTP.Method
---@param uri string
---@param opts HTTP.RequestOptions
---@param callback fun(method: HTTP.Method, uri: string, opts: HTTP.RequestOptions, callback: fun(ok: boolean, res: any))
---@return nil
---@overload async fun(method: HTTP.Method, uri: string, opts: HTTP.RequestOptions): any
function M.http(method, uri, opts, callback)
  local request = require("sidecar").request
  local co, main = coroutine.running()
  if co == nil or main or callback then
    request(method, uri, opts or {}, callback or function() end)
  elseif co then
    local function cb(err, res)
      coroutine.resume(co, err, res)
    end
    request(method, uri, opts or {}, cb)
    return coroutine.yield()
  end
end

return M
