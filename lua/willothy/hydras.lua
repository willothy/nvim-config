local function telescope(picker)
  local menufacture = require("telescope").extensions.menufacture[picker]
  if menufacture then
    return menufacture
  else
    return require("telescope.builtin")[picker]
  end
end

--- Lazy-load hydras on body keys
local Hydra = function(hintfunc, config)
  vim.keymap.set(config.mode, config.body, function()
    vim.keymap.del(config.mode, config.body)
    config.hint = hintfunc(config)
    local h = require("hydra")(config)
    h:activate()
  end, { desc = "[Hydra] " .. config.name })
end

local cmd = require("hydra.keymap-util").cmd

Hydra(function(config)
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
  exits = Lines:new(
    vim
      .iter(exits)
      :map(function(exit) return exit.key end)
      :fold("", function(a, v)
        if first == true then
          first = false
          return "_" .. v .. "_"
        else
          return a .. ", " .. "_" .. v .. "_"
        end
      end) .. ": close"
  ):trim_trailing_whitespace()

  local vert_size = maps.dimensions[1]
    + exits.dimensions[1]
    + backups.dimensions[1]
    + 3

  local bg = backgrounds.space
  local btm = elements.misc.land_border:trim_trailing_whitespace()
  local fg = elements.telescope.dog:trim_trailing_whitespace()
  local drop = Lines:empty({ vert_size, bg.dimensions[2] })

  bg = bg:truncate_height(vert_size, 9)

  local map_col = bg.dimensions[2] - maps.dimensions[2] - 4

  return drop
    :overlay(bg)
    :overlay(btm, vert_size)
    :overlay(fg, (vert_size - fg.dimensions[1] + 1) - bg.dimensions[1], nil)
    :overlay(maps, 2, map_col, true)
    :overlay(backups, 3 + maps.dimensions[1], map_col, true)
    :overlay(exits, -1, map_col, false)
    :trim_trailing_whitespace()
    :escape()
    :render()
end, {
  name = "Telescope",
  config = {
    color = "blue",
    invoke_on_body = true,
    hint = {
      position = "middle",
      border = "rounded",
    },
  },
  mode = "n",
  body = "<leader>f",
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
      cmd("silent! UndotreeToggle"),
      { desc = "undotree" },
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
})
