local M = {}

local handlers = {}
local timer = nil
local DEBOUNCE_MS = 100

---Register a diagnostic handler with priority
---@param name string Handler name (for debugging)
---@param priority integer Lower = runs first
---@param fn fun(buf: integer, diagnostics: table[]) Handler function
function M.register_handler(name, priority, fn)
  handlers[#handlers + 1] = {
    name = name,
    priority = priority,
    fn = fn,
  }
  -- Sort by priority (lower = higher priority)
  table.sort(handlers, function(a, b)
    return a.priority < b.priority
  end)
end

---Dispatch diagnostic update to all registered handlers (batched)
---@param buf integer Buffer number
---@param diagnostics table[] List of diagnostics
function M.dispatch(buf, diagnostics)
  if timer then
    timer:stop()
  end

  if timer == nil or timer:is_closing() then
    timer = vim.uv.new_timer()
  end

  timer:start(DEBOUNCE_MS, 0, vim.schedule_wrap(function()
    -- Update global diagnostic counts in reactive state
    local state = require("willothy.core.state")
    local counts = { errors = 0, warnings = 0, info = 0, hints = 0 }

    for _, diag in ipairs(diagnostics) do
      if diag.severity == vim.diagnostic.severity.ERROR then
        counts.errors = counts.errors + 1
      elseif diag.severity == vim.diagnostic.severity.WARN then
        counts.warnings = counts.warnings + 1
      elseif diag.severity == vim.diagnostic.severity.INFO then
        counts.info = counts.info + 1
      elseif diag.severity == vim.diagnostic.severity.HINT then
        counts.hints = counts.hints + 1
      end
    end

    state.diagnostics.set(counts)

    -- Batch all handlers in single event loop iteration
    for _, handler in ipairs(handlers) do
      local ok, err = pcall(handler.fn, buf, diagnostics)
      if not ok then
        vim.notify(
          string.format("Diagnostic handler error in %s: %s", handler.name, err),
          vim.log.levels.ERROR
        )
      end
    end
  end))
end

---Get registered handlers (for debugging)
---@return table[] handlers List of registered handlers
function M.get_handlers()
  return vim.deepcopy(handlers)
end

return M
