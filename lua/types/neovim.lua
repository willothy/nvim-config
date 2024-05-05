local methods = {}

---@class Neovim
---@field private channel? number
---@field private pid? number
---@field private servername? string
---@field private job_opts? table<string, any>
---@field [string] fun(self: Neovim, ...): ...: any
local Neovim = {}

local function build_rpc_method(method)
  return function(self, ...)
    if not self.channel then
      error("Neovim instance is not running")
    end
    return vim.rpcrequest(self.channel, method, ...)
  end
end

function Neovim:__index(key)
  local method = methods[key] or build_rpc_method(key)

  self[key] = method
  methods[key] = method

  return method
end

function Neovim:__tostring()
  return "<neovim>"
end

local COMMAND = { "nvim", "--embed", "--headless" }
local DEFAULT_JOBOPTS = {
  width = 80,
  height = 40,
}
local REQUIRED_JOBOPTS = {
  rpc = true,
}

function Neovim.new(job_opts)
  local self = {
    channel = nil,
    pid = nil,
    servername = nil,
    job_opts = job_opts or {},
  }
  return setmetatable(self, Neovim)
end

function Neovim:start()
  local job_opts = vim.tbl_extend(
    "force",
    DEFAULT_JOBOPTS,
    self.job_opts or {},
    REQUIRED_JOBOPTS
  )

  self.channel = vim.fn.jobstart(COMMAND, job_opts)

  if self.channel <= 0 then
    error("Failed to start Neovim instance")
  end
end

function Neovim:exec_lua(pure_fn)
  local chunk = string.dump(pure_fn)
  return self:nvim_exec_lua(([[
    return loatstring("%s")(...)
  ]]):format(chunk))
end

return Neovim
