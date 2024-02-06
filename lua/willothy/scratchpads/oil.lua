local M = {}

local Input = require("nui.input")
local Layout = require("nui.layout")
local Line = require("nui.line")
local Menu = require("nui.menu")
local Popup = require("nui.popup")
local Split = require("nui.split")
local Table = require("nui.table")
local Text = require("nui.text")
local Tree = require("nui.tree")

local Oil = {}

local layout

local octal = function(str)
  str = tostring(str)
  local decimal = 0
  for char in str:gmatch(".") do
    local n = tonumber(char, 8)
    if not n then
      return 0
    end
    decimal = decimal * 8 + n
  end
  return decimal
end

local popup = function(enter)
  local self = Popup({
    border = "single",
    enter = enter,
  })

  self:map("n", "p", function()
    local str = vim.inspect(self)
    local nio = require("nio")
    nio.run(function()
      local err, fd =
        nio.uv.fs_open("/home/willothy/.config/nvim/nui.log", "w+", octal(755))
      if err or not fd then
        vim.notify("Failed to open file: " .. err, vim.log.levels.ERROR)
        return
      end

      local size = string.len(str)
      local to_write = size
      while to_write > 0 do
        local written
        err, written = nio.uv.fs_write(fd, str)
        if err or not written then
          vim.notify("Failed to read file: " .. err, vim.log.levels.ERROR)
          return
        end
        to_write = to_write - written
        break
      end

      local ok
      err, ok = nio.uv.fs_close(fd)
      if err or not ok then
        vim.notify("Failed to close file: " .. err, vim.log.levels.ERROR)
      end
      return size
    end, function(ok, size)
      if not ok then
        vim.notify("Failed to write file: " .. size, vim.log.levels.ERROR)
      end
      vim.notify(("Wrote %d bytes to file"):format(size), vim.log.levels.INFO)
    end)
  end)

  self:map("n", "v", function()
    -- Oil.insert(self, "left")
    layout:update()
  end)

  self:map("n", "q", function()
    layout:unmount()
  end)

  return self
end

layout = Layout(
  {
    position = "50%",
    size = {
      width = "80%",
      height = "80%",
    },
  },
  Layout.Box({
    Layout.Box(popup(true), { size = "50%", name = "alkiuehfa" }),
    Layout.Box(popup(), { size = "50%", name = "eeee" }),
  }, { dir = "row" })
)

---@param node NuiLayout.Box
local function traverse_inner(node, parent, cb)
  local container = node
  if container.component then
    local component = container.component --[[@as NuiPopup]]
    cb(component, container, parent)
  else
    local box = container.box --[[@as NuiLayout.Box[] ]]
    for _, child in ipairs(box) do
      traverse_inner(child, container, cb)
    end
  end
end

local function traverse(root, cb)
  traverse_inner(root._.box, nil, cb)
end

---@param win NuiPopup
function Oil.find_parent(win, cb)
  local winid = win.winid
  local callback = function(box, _, parent)
    if box.winid == winid then
      local idx
      for i = 1, #parent.box do
        if parent.box[i].component.winid == winid then
          idx = i
          break
        end
      end
      cb(box, parent, idx)
    end
  end
  traverse(layout, callback)
end

---@param box NuiPopup
function Oil.insert(box, direction)
  Oil.find_parent(box, function(b, parent, idx)
    local new_box = Layout.Box(
      popup(false),
      { size = {
        width = "50%",
        height = "50%",
      } }
    )
    if parent.dir == "row" and (direction == "up" or direction == "down") then
      -- TODO: add new box above / below parent
    elseif
      parent.dir == "column" and (direction == "left" or direction == "right")
    then
      -- TODO: add new box left / right of parent
    end
    if direction == "left" then
      table.insert(parent.box, idx, new_box)
    elseif direction == "right" then
      table.insert(parent.box, idx + 1, new_box)
    elseif direction == "up" then
      table.insert(parent.box, idx, new_box)
    elseif direction == "down" then
      table.insert(parent.box, idx + 1, new_box)
    end
  end)
end

-- local i = 0
-- ---@param box NuiPopup
-- ---@param container NuiLayout.Box # The box wrapping the popup
-- ---@param parent NuiLayout.Box    # The box wrapping the row / column
-- traverse(layout, function(box, container, parent)
--   -- vim.print(box._.id .. ": " .. box:__tostring())
--   vim.print(parent.box)
--   i = i + 1
-- end)
-- vim.print(i)

layout:mount()

-- vim.print(layout.winid)

-- _G.L = layout

return M
