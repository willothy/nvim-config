-- if not _G.bruhbuf then _G.bruhbuf = vim.api.nvim_create_buf(false, true) end
-- local buf = _G.bruhbuf
--
-- local config = {
--   relative = "editor",
--   style = "minimal",
--   border = "single",
-- }
--
-- local width = 40
-- local height = 15
--
-- config.width = width
-- config.height = height
-- config.row = vim.o.lines - height
-- config.col = vim.o.columns - width
--
-- if not _G.bruhwin then
--   _G.bruhwin = vim.api.nvim_open_win(buf, false, config)
-- end
-- local win = _G.bruhwin
--
-- local ns = vim.api.nvim_create_namespace("bufui")
--
-- local id = 1
-- -- WhichKeyDesc
-- -- WhichKeyValue
-- -- WhichKeySeparator
-- -- WhichKeyGroup
-- -- WhichKey
-- vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
--   id = id,
--   virt_text_pos = "overlay",
--   virt_text = {
--     { "x", "WhichKey" },
--     { " " },
--     { "->", "WhichKeySeparator" },
--     { " " },
--     { "+cut", "WhichKeyGroup" },
--   },
--   virt_lines = {
--     { { "Line1", "Normal" } },
--     { { "Line3", "Visual" } },
--   },
-- })

local mode = "o"
local map = "i"

vim.on_key(vim.schedule_wrap(function(k)
  if k == vim.api.nvim_replace_termcodes("<space>", true, false, true) then
    require("which-key").show(" ")
    -- local kmap = vim.api.nvim_get_keymap(vim.api.nvim_get_mode().mode)
  end
  -- local found = vim
  --   .iter(kmap)
  --   :filter(function(mapping)
  --     return vim.startswith(mapping.lhs, map)
  --   end)
  --   :totable()
  -- vim.print(found)
end))
