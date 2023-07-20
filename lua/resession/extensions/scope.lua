local M = {}

function M.on_save() return require("scope.session").serialize_state() end

function M.on_load(state)
  require("scope")
  return require("scope.session").deserialize_state(state)
end

return M
