local api = vim.api
local hydra = require("hydra.statusline")

local Modenr = {}

local mode_names = {
  ["n"] = "Normal",
  ["i"] = "Insert",
  ["v"] = "Visual",
  ["V"] = "Visual",
  [""] = "Visual",
  ["s"] = "Select",
  ["S"] = "Select",
  ["R"] = "Replace",
  ["c"] = "Command",
  ["t"] = "Terminal",
  ["nt"] = "TerminalNormal",
}

function Modenr.get_color(evt)
  evt = evt or ""
  local mode = mode_names[api.nvim_get_mode().mode] or "Normal"
  local hl = api.nvim_get_hl(0, { name = mode .. "Mode", link = false })

  if hydra.is_active() and evt ~= "HydraLeave" then
    local color = hydra.get_color()
    if color == "pink" then
      color = require("minimus.palette").hex.red
    elseif color == "red" then
      color = require("minimus.palette").hex.persian_red
    elseif color == "blue" then
      color = require("minimus.palette").hex.blue
    elseif color == "teal" then
      color = require("minimus.palette").hex.teal
    elseif color == "amaranth" then
      color = require("minimus.palette").hex.flamingo
    end

    hl.fg = color
  end

  return hl
end

function Modenr.get_name()
  if hydra.is_active() then
    return hydra.get_name()
  else
    return mode_names[api.nvim_get_mode().mode] or "Normal"
  end
end

function Modenr.setup()
  local function update_mode(ev)
    local hl = Modenr.get_color(ev.file)
    api.nvim_set_hl(0, "CursorLineNr", hl)
  end
  update_mode({})

  local group = api.nvim_create_augroup("Modenr", { clear = true })
  api.nvim_create_autocmd("ModeChanged", {
    group = group,
    callback = update_mode,
  })
  api.nvim_create_autocmd("User", {
    pattern = "HydraEnter",
    group = group,
    callback = update_mode,
  })
  api.nvim_create_autocmd("User", {
    pattern = "HydraLeave",
    group = group,
    callback = update_mode,
  })
end

return Modenr
