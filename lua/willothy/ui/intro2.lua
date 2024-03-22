local Line = require("nui.line")

---@alias Wintro.Dynamic<T> T | fun(): T

---@alias Wintro.View Wintro.Dynamic<Wintro.Dynamic<Wintro.Line>[]>

---@class Wintro.Widget
---@field view Wintro.View
---@field private buffer NuiLine[]
local Widget = {}

---@class Wintro.Chunk
---@field [1] Wintro.Dynamic<string>
---@field [2] Wintro.Dynamic<string>

---@class Wintro.Line
---@field [integer] Wintro.Dynamic<Wintro.Chunk>

---@param view Wintro.View?
function Widget:new(view)
  local new = {
    view = view,
  }

  self.__index = self

  return setmetatable(new, self)
end

---@param view Wintro.View
function Widget:enter(view)
  self.view = view
end

---@generic T
---@param value Wintro.Dynamic<T>
local function eval(value)
  if type(value) == "function" then
    return value()
  end
  return value
end

function Widget:eval()
  local view = eval(self.view)
  if type(view) ~= "table" then
    vim.notify(
      "view must be a table",
      vim.log.levels.ERROR,
      { title = "Wintro" }
    )
    return {}
  end

  return vim
    .iter(view)
    :map(eval)
    :map(function(line)
      return vim
        .iter(line)
        :map(eval)
        :map(unpack)
        :fold(Line(), function(nuiline, text, hl)
          nuiline:append(eval(text), eval(hl))

          return nuiline
        end)
    end)
    :totable()
end
