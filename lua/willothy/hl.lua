local bit = require("bit")

local M = {}

---@param rgb number
---Converts an rgb number into a hex string
function M.hex(rgb)
  local r = bit.rshift(bit.band(rgb, 0xff0000), 16)
  local g = bit.rshift(bit.band(rgb, 0x00ff00), 8)
  local b = bit.band(rgb, 0x0000ff)

  return ("#%02x%02x%02x"):format(r, g, b)
end

---Alias to `vim.api.nvim_get_hl_id_by_name`
M.hl_id = vim.api.nvim_get_hl_id_by_name

---Alias to `vim.api.nvim_get_hl_by_id`
M.hl_by_id = vim.api.nvim_get_hl

local sanitize = {
  foreground = "fg",
  background = "bg",
  guifg = "fg",
  guibg = "bg",
  bold = "bold",
  underline = "underline",
  undercurl = "undercurl",
  italic = "italic",
  fg = "fg",
  bg = "bg",
  gui = function(self, gui)
    for _, g in ipairs({
      "bold",
      "italic",
      "underline",
      "undercurl",
      "strikethrough",
    }) do
      if gui:find(g) then self[g] = true end
    end
    self.gui = nil
  end,
  style = function(self, style)
    for _, s in ipairs({
      "bold",
      "italic",
      "underline",
      "undercurl",
      "strikethrough",
    }) do
      if style:find(s) then self[s] = true end
    end
    self.style = nil
  end,
}

---@param hl table
function M.sanitize(hl)
  for k, v in pairs(hl) do
    if type(v) == "number" then hl[k] = M.hex(v) end
    if sanitize[k] then
      if type(sanitize[k]) == "string" then
        hl[sanitize[k]] = hl[k]
      elseif type(sanitize[k]) == "function" then
        sanitize[k](hl, v)
      end
    else
      hl[k] = nil
    end
  end
  return hl
end

---@param group string | integer
function M.hl(group)
  return M.hl_by_id(
    0,
    type(group) == "number" and { id = group } or { name = group }
  )
end

function M.fetch(group) return M.sanitize(M.hl(group)) end

function M.fetch_attr(group, attr) return M.sanitize(M.hl(group))[attr] end

-- local test_hl = {
--   bold = true,
--   italic = true,
--   underline = true,
--   undercurl = true,
--   strikethrough = true,
--   fg = 0xff0000,
--   bg = "0xf0faff",
-- }
--
-- print(M.sanitize(test_hl))
--
-- local test_hl_gui = {
--   gui = "bold,italic,underline,undercurl,strikethrough",
--   fg = 0xff0000,
--   bg = 0x00ffff,
-- }
-- print(M.sanitize(test_hl_gui))

return M
