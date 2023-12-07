local M = {}

function M.create(config)
  config = config or {}

  if config.client_name then
    config.lsp_name, config.client_name = config.client_name, nil
  end

  config.done = false

  return require("fidget.progress").handle.create(config)
end

-- -- Show progress in Wezterm tab bar
-- local fidget = require("fidget")
-- local async = require("micro-async")
--
-- _G.t = async.void(function()
-- 	if _G.t then
-- 		_G.t:cancel()
-- 	end
-- 	local pat = fidget.spinner.patterns.dots
-- 	local cur = 1
-- 	local next = function()
-- 		cur = cur + 1
-- 		if cur > #pat then
-- 			cur = 1
-- 		end
-- 		return cur
-- 	end
-- 	for _ = 1, 20 do
-- 		async.defer(100)
-- 		require("wezterm").set_user_var("sesh_name", "loading " .. pat[next()])
-- 	end
-- 	require("wezterm").set_user_var("sesh_name", nil)
-- end)()

return M
