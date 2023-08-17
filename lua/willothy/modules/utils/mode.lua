local api = vim.api
local hydra = require("hydra.statusline")

local M = {}

local mode_names = {
  ["n"] = "Normal",
  ["no"] = "Normal",
  ["i"] = "Insert",
  ["v"] = "Visual",
  ["vo"] = "Visual",
  ["V"] = "Visual",
  [""] = "Visual",
  ["s"] = "Select",
  ["S"] = "Select",
  ["R"] = "Replace",
  ["c"] = "Command",
  ["t"] = "Terminal",
  ["nt"] = "TerminalNormal",
}

function M.get_color(evt)
  evt = evt or ""

  local hl
  if hydra.is_active() and evt ~= "HydraLeave" then
    local color = hydra.get_color()
    if color == "pink" then
      hl = "HydraPink"
    elseif color == "red" then
      hl = "HydraRed"
    elseif color == "blue" then
      hl = "HydraBlue"
    elseif color == "teal" then
      hl = "HydraTeal"
    elseif color == "amaranth" then
      hl = "HydraAmaranth"
    end
  else
    local mode = mode_names[api.nvim_get_mode().mode] or "Normal"
    hl = mode .. "Mode"
  end

  return willothy.hl.hl(hl)
end

function M.get_name()
  if hydra.is_active() then
    return hydra.get_name()
  else
    return mode_names[api.nvim_get_mode().mode] or "Normal"
  end
end

function M.setup()
  local function update_mode(ev)
    local hl = M.get_color(ev.file)
    api.nvim_set_hl(0, "CursorLineNr", hl)
  end
  update_mode({})

  local group = api.nvim_create_augroup("Modenr", { clear = true })
  api.nvim_create_autocmd({ "ModeChanged" }, {
    group = group,
    callback = update_mode,
  })
  api.nvim_create_autocmd("User", {
    pattern = { "HydraEnter", "HydraLeave" },
    group = group,
    callback = update_mode,
  })
end

return M
