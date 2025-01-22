---@param str string
---@return table<string, string>, string[]
local function parse(str)
  local parsed = vim.api.nvim_parse_cmd(str, {})

  ---@type string[]
  local args = {}
  ---@type table<string, string>
  local flags = {}

  for _, arg in ipairs(parsed.args) do
    local k, v = string.match(arg, "^(%w+)=(^w*)")
    if k then
      flags[k] = v
    else
      table.insert(args, arg)
    end
  end

  return args, flags
end

---@class Command
---@field private _subcommands table<string, Command>
---@field private _execute fun(args: table<string, string>): nil
local Command = {}
Command.__index = Command

---@param execute? fun(args: table<string, string>)
---@return Command
function Command.new(execute)
  return setmetatable({
    _subcommands = {},
    _execute = execute or function() end,
  }, Command)
end

---@param name string
---@param command Command
---@return self
function Command:subcommand(name, command)
  self._subcommands[name] = command
  return self
end

---@param commands table<string, Command>
---@return self
function Command:subcommands(commands)
  for name, command in pairs(commands) do
    self._subcommands[name] = command
  end
  return self
end

function Command:_complete(args, flags)
  if args[#args] == "" then
    return vim.tbl_keys(self._subcommands)
  end

  local prefix = args[#args] or ""

  for k, v in pairs(self._subcommands) do
    if k == prefix then
      return v:_complete(vim.iter(args):skip(1):totable(), flags)
    end

    if string.match(k, "^" .. prefix) then
      table.insert(args, k)
    end
  end
end

function Command:complete(str)
  local args, flags = parse(str)

  return self:_complete(args, flags)
end

function Command:bind(name)
  -- ArgLead, CmdLine, CursorPos
  vim.api.nvim_create_user_command(name, function(args)
    return self._execute({})
    -- return self:complete(args.args)
  end, {
    ---@param arg_lead string
    ---@param cmdline string
    ---@param cursor_pos number
    complete = function(arg_lead, cmdline, cursor_pos)
      return self:complete(cmdline .. " " .. arg_lead)
    end,
    nargs = "*",
  })
end

local cmd = Command.new(function()
  vim.print("test")
end):subcommand(
  "two",
  Command.new(function()
    vim.print("foo subcmd")
  end)
)

cmd:bind("Foo")
