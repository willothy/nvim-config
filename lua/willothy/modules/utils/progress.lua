local M = {}

local handler = vim.lsp.handlers["$/progress"]

local _id = 0
local function next_token()
  local id = _id
  _id = _id + 1
  return "progress_" .. id
end

local _client
local function new_client(name, public)
  return vim.lsp.start({
    name = name or "progress",
    cmd = function(_dispatchers)
      local stopped = false
      return {
        request = function(method, params, callback)
          if method == "initialize" and public then
            callback(nil, {
              capabilities = {},
            })
          end
        end,
        notify = function(method, params)
          if method == "window/progress" then
            handler(nil, params)
          end
        end,
        is_closing = function()
          return stopped
        end,
        stop = function()
          stopped = true
        end,
      }
    end,
  })
end

local function get_client()
  if _client == nil then
    _client = new_client()
  end
  return _client
end

function M.create(config)
  config = config or {}
  local handle = {}

  local token = next_token()
  local client = get_client()
  local started = false
  local running = false

  local value = {
    title = config.title,
    message = config.message,
    percentage = config.percentage,
  }

  local function send()
    handler(nil, {
      token = token,
      value = value,
    }, { client_id = client, client = config.client })
  end

  function handle:begin()
    if started == true then
      return
    end

    value.kind = "begin"
    send()

    started = true
    running = true
  end

  function handle:report(opts)
    if started == false or running == false then
      return
    end
    opts = opts or {}

    value.kind = "report"
    value.title = opts.title or value.title
    value.message = opts.message or value.message
    value.percentage = opts.percentage or value.percentage

    send()
  end

  function handle:finish(opts)
    if started == true and running == false then
      return
    end
    opts = opts or {}

    value.kind = "end"
    value.title = opts.title or value.title
    value.message = opts.message or value.message
    value.percentage = value.percentage and 100 or nil

    send()
    running = false
  end

  return handle
end

return M
