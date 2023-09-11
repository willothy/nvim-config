local bit = require("bit")

local M = {}

local cache = {
  hex = {},
  groups = {},
}

-- Invalidate the cache on colorscheme change
vim.api.nvim_create_autocmd("Colorscheme", {
  group = vim.api.nvim_create_augroup(
    "cokeline_color_cache",
    { clear = true }
  ),
  callback = function()
    cache.groups = {}
  end,
})

---@param rgb integer
---@return string hex
function M.hex(rgb)
  if type(rgb) ~= "number" then
    return rgb and tostring(rgb) or nil
  end
  if cache.hex[rgb] then
    return cache.hex[rgb]
  end
  local band, lsr = bit.band, bit.rshift

  local r = lsr(band(rgb, 0xff0000), 16)
  local g = lsr(band(rgb, 0x00ff00), 8)
  local b = band(rgb, 0x0000ff)

  local res = ("#%02x%02x%02x"):format(r, g, b)
  cache.hex[rgb] = res
  return res
end

---Alias to `vim.api.nvim_get_hl_id_by_name`
M.hl_id = vim.api.nvim_get_hl_id_by_name

---Alias to `vim.api.nvim_get_hl_by_id`
M.hl_by_id = vim.api.nvim_get_hl

---@param group string | integer
function M.hl(group)
  if not group then
    return
  end
  if cache.groups[group] then
    return cache.groups[group]
  end
  local hl = vim.api.nvim_get_hl(
    0,
    type(group) == "number" and { id = group, link = false }
      or { name = group, link = false }
  )
  hl = M.sanitize(hl)
  cache.groups[group] = hl
  return hl
end

function M.sanitize(hl)
  for k, v in pairs(hl) do
    if type(v) == "number" then
      hl[k] = M.hex(v)
    end
  end
  return hl
end

function M.fetch_attr(group, attr)
  return M.hl(group)[attr]
end

function M.get(group, attr)
  group = M.hl(group)
  if group and attr then
    return group[attr]
  end
  return group
end

return M
