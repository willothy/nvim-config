---@module 'blink.copilot'

---@class blink.Copilot
---@field private _api any
local Copilot = {}

Copilot.__index = Copilot

function Copilot.new()
  return setmetatable({
    _api = require("copilot.api"),
  }, Copilot)
end

-- function Copilot:get_trigger_characters()
-- return self:api().get_trigger_characters()
-- end

function Copilot:enabled()
  return true
end

function Copilot:api()
  ---@module "copilot.api"
  local api = self._api
  return api
end

function Copilot:get_completions(ctx, callback)
  local copilot_util = require("copilot.util")
  local client_lib = require("copilot.client")
  local client = client_lib.get()
  if not client then
    client_lib.setup()
    client = client_lib.get()
  end
  assert(client)

  local params = copilot_util.get_doc_params()
  params.context = ctx
  self
    :api()
    .get_completions_cycling(client, params, function(_err, res, _params)
      res = res or {}

      if res.completions then
        res.completions = vim
          .iter(res.completions)
          :map(function(item)
            return {
              label = vim.split(
                vim.trim(item.text),
                "\n",
                { trimempty = true }
              )[1],

              kind = require("blink.cmp.types").CompletionItemKind.Copilot,
              insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
              insertTextMode = 2,
              documentation = vim
                .iter(vim.split(item.text, "\n"))
                :map(function(s)
                  local x = s:gsub("^%s%s", "")

                  return x
                end)
                :join("\n"),
              textEdit = {
                range = item.range,
                newText = item.text:gsub("%s+$", ""),
              },
            }
          end)
          :totable()
      end

      callback({
        -- context = params.context,
        context = ctx,
        is_incomplete_forward = false,
        is_incomplete_backward = false,
        items = res.completions or {},
        itemDefaults = {
          insertTextMode = 2,
        },
      })
    end)

  -- TODO: cancel inflight requests
  return function() end
end

return Copilot
