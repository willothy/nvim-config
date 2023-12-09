local bit = require("bit")

---@class Bitmask
---@field private mask integer
local Bitmask = {}
Bitmask.__index = Bitmask

---@param mask integer?
function Bitmask.new(mask)
  return setmetatable({
    mask = mask or 0,
  }, Bitmask)
end

---@param idx integer
function Bitmask:set(idx)
  if idx > 64 then
    error("Index out of bounds")
  end
  self.mask = bit.bor(self.mask, bit.lshift(1, idx))
end

---@param idx integer
function Bitmask:unset(idx)
  if idx > 64 then
    error("Index out of bounds")
  end
  self.mask = bit.band(self.mask, bit.bnot(bit.lshift(1, idx)))
end

---@param idx integer
---@return boolean
function Bitmask:get(idx)
  if idx > 64 then
    error("Index out of bounds")
  end
  return bit.band(self.mask, bit.lshift(1, idx)) ~= 0
end

---@param idx integer
function Bitmask:toggle(idx)
  if idx > 64 then
    error("Index out of bounds")
  end
  self.mask = bit.bxor(self.mask, bit.lshift(1, idx))
end

---@return integer
function Bitmask:into_raw()
  return self.mask
end

return Bitmask
