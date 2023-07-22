local M = {}

function M.on_save()
  local core = require("scope.core")
  local utils = require("scope.utils")
  local scope_cache = {}
  for k, v in pairs(core.cache) do
    scope_cache[k] = utils.get_buffer_names(v)
  end
  return {
    cache = scope_cache,
    last_tab = core.last_tab,
  }
end

function M.on_load(state)
  local utils = require("scope.utils")
  local scope_state = state or {}
  local cache = {}
  for _, table in pairs(scope_state.cache or {}) do
    cache[#cache + 1] = utils.get_buffer_ids(table)
  end
  require("scope.core").cache = cache
  require("scope.core").last_tab = scope_state.last_tab
  require("scope.core").on_tab_enter()
end

return M
