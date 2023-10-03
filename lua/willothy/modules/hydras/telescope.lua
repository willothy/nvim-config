local telescope = willothy.fn.telescope
local Hydra = require("willothy.modules.hydras").Hydra

local hint = function(config)
  ---@type Lines
  local Lines = require("willothy.lines")
  local backgrounds = require("willothy.lines.backgrounds")
  local elements = require("willothy.lines.elements")

  local keys = {}
  local exits = {}
  local ends = {}

  for _, head in ipairs(config.heads) do
    if head[3].ends then
      table.insert(ends, { key = head[1], desc = head[3].desc or "" })
    elseif head[3].exit == true then
      table.insert(exits, { key = head[1], desc = head[3].desc or "" })
    else
      table.insert(keys, { key = head[1], desc = head[3].desc or "" })
    end
  end

  local maps = Lines:actions(keys):trim_trailing_whitespace()

  local backups = {}
  vim.iter(ends):each(function(action)
    table.insert(backups, action)
    table.insert(backups, { key = "", desc = "" })
  end)
  backups = Lines:actions(backups):trim_trailing_whitespace()

  local first = true
  exits = Lines:new(vim
    .iter(exits)
    :map(function(exit)
      return exit.key
    end)
    :fold("", function(a, v)
      if first == true then
        first = false
        return "_" .. v .. "_"
      else
        return a .. ", " .. "_" .. v .. "_"
      end
    end) .. ": close"):trim_trailing_whitespace()

  local vert_size = maps.dimensions[1]
    + exits.dimensions[1]
    + backups.dimensions[1]
    + 3

  local bg = backgrounds.space
  local drop = Lines:empty({ vert_size, bg.dimensions[2] })

  bg = bg:truncate_height(vert_size, 9)

  return drop
    :overlay(maps, 1, 1, true)
    :overlay(backups, 2 + maps.dimensions[1], 1, true)
    :overlay(exits, 4 + maps.dimensions[1], 1, false)
    :trim_trailing_whitespace()
    :escape()
    :render()
end

local config = {

  name = "Telescope",
  config = {
    color = "blue",
    invoke_on_body = true,
    hint = {
      position = "bottom-left",
      border = "single",
    },
  },
  mode = "n",
  body = "<leader>vt",
  heads = {
    {
      "s",
      telescope("live_grep"),
      { desc = "live grep" },
    },
    {
      "f",
      telescope("find_files"),
      { desc = "find files" },
    },
    {
      "g",
      telescope("git_files"),
      { desc = "git files" },
    },
    { "r", telescope("resume"), { desc = "resume" } },
    {
      "p",
      telescope("projects"),
      { desc = "projects" },
    },
    {
      "u",
      telescope("undo"),
      { desc = "edit hist." },
    },
    {
      "<Enter>",
      telescope("builtin"),
      { desc = "pickers", ends = true },
    },
    {
      "<Esc>",
      nil,
      { exit = true, nowait = true, desc = "close" },
    },
    { "q", nil, { exit = true, nowait = true, desc = "close" } },
  },
}

config.hint = hint(config)

return Hydra(config)
