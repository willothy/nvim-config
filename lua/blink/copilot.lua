---@module 'blink.cmp'

local M = {} ---@as blink.cmp.Source

function M.new()
  return setmetatable({
    source = require("copilot_cmp.source").n
  }, { __index = M })
end

function M:get_trigger_characters()
  return { '"', "'", ".", "/" }
end

function M:enabled()
  --
end

function M:get_completions(ctx, callback)
  local before = string.sub(ctx.line, 1, ctx.cursor[2])

  local transformed_callback = function(items)
    callback({
      context = ctx,
      is_incomplete_forward = false,
      is_incomplete_backward = false,
      items = items,
    })
  end

  local items = {} ---@type table<string,lsp.CompletionItem>

  transformed_callback(vim.tbl_values(items))

  -- require("copilot_cmp")._on_insert_enter({
  --
  -- })

  -- TODO: cancel run_async
  return function() end
end

return M
