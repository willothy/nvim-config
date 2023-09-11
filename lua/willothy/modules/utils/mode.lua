local api = vim.api

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
  -- ["nt"] = "TerminalNormal",
  ["nt"] = "Normal",
}

function M.get_color(evt)
  evt = evt or ""

  local hl
  local hydra = package.loaded.hydra and require("hydra.statusline")
  if hydra and hydra.is_active() and evt ~= "HydraLeave" then
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

  local function hex(rgb)
    if type(rgb) == "string" then
      return rgb
    end
    local bit = require("bit")
    local r = bit.rshift(bit.band(rgb, 0xff0000), 16)
    local g = bit.rshift(bit.band(rgb, 0x00ff00), 8)
    local b = bit.band(rgb, 0x0000ff)

    return ("#%02x%02x%02x"):format(r, g, b)
  end

  hl = vim.api.nvim_get_hl(0, { name = hl })
  if hl.fg then
    hl.fg = hex(hl.fg)
  end
  if hl.bg then
    hl.bg = hex(hl.bg)
  end
  if hl.sp then
    hl.sp = hex(hl.sp)
  end
  return hl
  -- return willothy.hl.hl(hl)
end

function M.get_name()
  local hydra = package.loaded.hydra and require("hydra.statusline")
  if hydra and hydra.is_active() then
    return hydra.get_name()
  else
    return mode_names[api.nvim_get_mode().mode] or "Normal"
  end
end

-- function M.setup()
--   local function update_mode(ev)
--     local hl = M.get_color(ev.file)
--     api.nvim_set_hl(0, "CursorLineNr", hl)
--   end
--   update_mode({})
--
--   local group = api.nvim_create_augroup("Modenr", { clear = true })
--   api.nvim_create_autocmd({ "ModeChanged" }, {
--     group = group,
--     callback = update_mode,
--   })
--   api.nvim_create_autocmd("User", {
--     pattern = { "HydraEnter", "HydraLeave" },
--     group = group,
--     callback = update_mode,
--   })
-- end

return M
