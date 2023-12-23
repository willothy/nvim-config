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

local cache = {}

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

  if cache[hl] then
    return cache[hl]
  end

  cache[hl] = vim.api.nvim_get_hl(0, { name = hl, link = false })

  return cache[hl]
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

local function update_mode(ev)
  local hl = M.get_color(ev and ev.file)
  vim.api.nvim_set_hl(0, "CurrentMode", hl)
end

local function highlight()
  cache = {}
  local p = require("minimus").hex
  vim.api.nvim_set_hl(0, "NormalMode", { fg = p.turquoise })
  vim.api.nvim_set_hl(0, "InsertMode", { fg = p.pale_azure })
  vim.api.nvim_set_hl(0, "VisualMode", { fg = p.lemon_chiffon })
  vim.api.nvim_set_hl(0, "ReplaceMode", { fg = p.lavender_pink })
  vim.api.nvim_set_hl(0, "TerminalMode", { fg = p.peach })
  vim.api.nvim_set_hl(0, "CommandMode", { fg = p.peach })

  -- lifted these from Hydra since they're being set in a plugin file, which we don't load
  -- because it's not loaded on an event with lazy
  vim.api.nvim_set_hl(0, "HydraRed", { fg = "#ff5733", bold = true })
  vim.api.nvim_set_hl(0, "HydraBlue", { fg = "#5ebcf6", bold = true })
  vim.api.nvim_set_hl(0, "HydraAmaranth", { fg = "#ff1757", bold = true })
  vim.api.nvim_set_hl(0, "HydraTeal", { fg = "#00a1a1", bold = true })
  vim.api.nvim_set_hl(0, "HydraPink", { fg = "#ff55de", bold = true })

  vim.api.nvim_set_hl(0, "HydraHint", { link = "NormalFloat" })
  vim.api.nvim_set_hl(0, "HydraBorder", { link = "CurrentMode" })
end

function M.setup()
  local group = vim.api.nvim_create_augroup("willothy/mode", { clear = true })

  highlight()
  update_mode({})

  vim.api.nvim_create_autocmd({ "ModeChanged" }, {
    group = group,
    callback = update_mode,
  })
  vim.api.nvim_create_autocmd("User", {
    pattern = { "HydraEnter", "HydraLeave" },
    group = group,
    callback = update_mode,
  })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = highlight,
  })
end

return M
