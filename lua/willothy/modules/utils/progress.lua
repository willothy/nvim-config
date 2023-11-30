local M = {}

function M.create(config)
  config = config or {}

  if config.client_name then
    config.lsp_name, config.client_name = config.client_name, nil
  end

  config.done = false

  return require("fidget.progress").create(config)
end

return M
