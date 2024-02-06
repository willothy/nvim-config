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
    Layout.Box(popup(true), { size = "50%" }),
    Layout.Box(popup(), { size = "50%" }),
  }, { dir = "row" })
)

layout:mount()

vim.print(layout.winid)

return M
