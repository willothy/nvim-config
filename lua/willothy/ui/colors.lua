local M = {}

local lush = require("lush")
local hsl = lush.hsl

--- WIP: This is a work in progress and is not ready for use.
---
--- This module creates a simple API for defining and editing plugin highlight groups
--- that automatcially update when the colorscheme changes.

local augroup

---@class Willothy.Highlight
---@field fg? Willothy.Color
---@field bg? Willothy.Color
---@field sp? Willothy.Color
---@field bold? boolean
---@field italic? boolean
---@field underline? boolean
---@field undercurl? boolean
---@field strikethrough? boolean

---@class Willothy.Color.Link
---@field attr "fg" | "bg" | "sp"
---@field group string

---@class Willothy.Color.Source
---@field type "link" | "hex" | "rgb" | "function"
---@field value Willothy.Color.Link | string | fun(): Willothy.LushHSL | { r: number, g: number, b: number }

---@class Willothy.Color
---@field source Willothy.Color.Source
local Color = {}

Color.__index = Color

---@param hlgroup string
---@param attr "fg" | "bg" | "sp"
function Color.new_link(hlgroup, attr)
  local self = {}

  self.source = {
    type = "link",
    value = {
      attr = attr,
      group = hlgroup,
    },
  }

  return setmetatable(self, Color)
end

---@param r number
---@param g number
---@param b number
---@return Willothy.Color
function Color.new_rgb(r, g, b)
  local self = {}
  self.source = {
    type = "rgb",
    value = {
      r,
      g,
      b,
    },
  }
  return setmetatable(self, Color)
end

---@param hex string
---@return Willothy.Color
function Color.new_hex(hex)
  local self = {}
  self.source = {
    type = "hex",
    value = hex,
  }
  return setmetatable(self, Color)
end

function Color:evaluate()
  local source = self.source
  if source.type == "link" then
    local link = source.value
    local group = vim.api.nvim_get_hl(0, {
      link = false,
      name = link.group,
    })
    local bit = require("bit")
    local band, lsr = bit.band, bit.rshift

    local rgb = group[link.attr]
    local r = lsr(band(rgb, 0xff0000), 16)
    local g = lsr(band(rgb, 0x00ff00), 8)
    local b = band(rgb, 0x0000ff)
    return hsl(r, g, b)
  elseif source.type == "hex" then
    return hsl(source.value)
  elseif source.type == "rgb" then
    return hsl(source.value[1], source.value[2], source.value[3])
  elseif source.type == "function" then
    return source.value()
  end
  return hsl("#000000")
end

---@alias Willothy.LushHSL any

---@param transformer fun(color: Willothy.LushHSL): Willothy.Color
---@return Willothy.Color
function Color:_transform(transformer)
  local new = {
    source = {
      type = "function",
      value = function()
        local color = self:evaluate()
        return transformer(color)
      end,
    },
  }

  return setmetatable(new, Color)
end

---@param amount integer
---@return Willothy.Color
function Color:lighten(amount)
  return self:_transform(function(color)
    return color.lighten(amount)
  end)
end

---@param amount integer
---@return Willothy.Color
function Color:darken(amount)
  return self:_transform(function(color)
    return color.darken(amount)
  end)
end

---@param amount integer
---@return Willothy.Color
function Color:saturate(amount)
  return self:_transform(function(color)
    return color.saturate(amount)
  end)
end

---@param amount integer
---@return Willothy.Color
function Color:desaturate(amount)
  return self:_transform(function(color)
    return color.desaturate(amount)
  end)
end

---@class Willothy.HlGroup
---@field name string
---@field value Willothy.Highlight
local Group = {}

Group.__index = Group

---@param name string
---@param value Willothy.Highlight
function Group.new(name, value)
  local self = {
    name = name,
    value = value,
  }
  return setmetatable(self, Group)
end

function Group:apply()
  local computed = {}

  for k, v in pairs(self.value) do
    if type(v) == "table" then
      computed[k] = v:evaluate()
    else
      computed[k] = v
    end
  end

  vim.api.nvim_set_hl(0, self.name, computed)
end

local Plugins = {}

function M.register(plugin, groups)
  Plugins[plugin] = groups
end

function M.update()
  for _, groups in pairs(Plugins) do
    for _, group in ipairs(groups) do
      group:apply()
    end
  end
end

function M.setup()
  augroup = vim.api.nvim_create_augroup("willothy/ui/colors", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = vim.schedule_wrap(M.update),
    desc = "Update plugin hlgroups on colorscheme change",
  })
end

M.Color = Color
M.Group = Group

return M
