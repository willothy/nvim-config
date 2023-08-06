local M = {}

function M.find(mode, lhs)
  local map = vim.api.nvim_get_keymap(mode)
  local raw = vim.api.nvim_replace_termcodes(lhs, true, false, false)

  for _, m in ipairs(map) do
    if m.lhs == lhs or m.lhsraw == raw then return m end
  end
end

return M
