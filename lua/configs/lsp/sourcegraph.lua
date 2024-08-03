-- vim.env.SRC_ENDPOINT = "https://sourcegraph.com"

require("sg").setup({
  -- enable_cody = true,
  -- download_binaries = false,
})

-- local auth = require("sg.auth")
--
-- if auth.get() == nil then
--   require("1password").read(
--     "op://Private/Sourcegraph API/credential",
--     vim.schedule_wrap(function(data, err)
--       if err ~= nil then
--         vim.notify(
--           "Error reading 1Password item: " .. err,
--           vim.log.levels.ERROR,
--           {
--             title = "Sourcegraph",
--           }
--         )
--         return
--       end
--
--       auth.set("https://sourcegraph.com", vim.trim(data), {
--         initialize = true,
--       })
--     end)
--   )
-- end
