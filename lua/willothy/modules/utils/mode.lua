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


-- stylua: ignore start
local mode_short_names = {
  ['n']      = 'NO',
  ['no']     = 'OP',
  ['nov']    = 'OC',
  ['noV']    = 'OL',
  ['no\x16'] = 'OB',
  ['\x16']   = 'VB',
  ['niI']    = 'IN',
  ['niR']    = 'RE',
  ['niV']    = 'RV',
  ['nt']     = 'NT',
  ['ntT']    = 'TM',
  ['v']      = 'VI',
  ['vs']     = 'VI',
  ['V']      = 'VL',
  ['Vs']     = 'VL',
  ['\x16s']  = 'VB',
  ['s']      = 'SE',
  ['S']      = 'SL',
  ['\x13']   = 'SB',
  ['i']      = 'IN',
  ['ic']     = 'IC',
  ['ix']     = 'IX',
  ['R']      = 'RE',
  ['Rc']     = 'RC',
  ['Rx']     = 'RX',
  ['Rv']     = 'RV',
  ['Rvc']    = 'RC',
  ['Rvx']    = 'RX',
  ['c']      = 'CO',
  ['cv']     = 'CV',
  ['r']      = 'PR',
  ['rm']     = 'PM',
  ['r?']     = 'P?',
  ['!']      = 'SH',
  ['t']      = 'TE',
}
-- stylua: ignore end

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
end

function M.get_name()
  local hydra = package.loaded.hydra and require("hydra.statusline")
  if hydra and hydra.is_active() then
    return hydra.get_name()
  else
    return mode_names[api.nvim_get_mode().mode] or "Normal"
  end
end

function M.get_short_name()
  local hydra = package.loaded.hydra and require("hydra.statusline")
  if hydra and hydra.is_active() then
    if _G["Hydra"] and _G["Hydra"].config.stl_name then
      return _G["Hydra"].config.stl_name
    end
    return hydra.get_name()
  else
    return mode_short_names[api.nvim_get_mode().mode] or "NO"
  end
end

return M
