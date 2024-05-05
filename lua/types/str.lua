local M = {}

---@param str string
---@param args table<string, any>
---@return string
function M.fmt(str, args)
  -- use regular string.format for positional arguments
  str = string.format(str, unpack(args))

  for k, v in pairs(args) do
    if type(k) == "string" then
      str = str:gsub("{" .. k .. "}", v)
    end
  end

  str = str:gsub("{{", "{"):gsub("}}", "}")

  return str
end

---@type stringlib
local stringlib = getmetatable("")

stringlib.fmt = M.fmt

---Positional and named arguments
---
---"%s {name}!" % { "hello", name = "world" } -> "hello world!"
stringlib.__mod = M.fmt

return M
