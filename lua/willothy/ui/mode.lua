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

---@param ignore_cache? boolean
function M.get_color(ignore_cache)
  local mode = mode_names[api.nvim_get_mode().mode] or "Normal"
  local hl = mode .. "Mode"

  if cache[hl] and not ignore_cache then
    return cache[hl]
  end

  -- If the highlight group doesn't exist, return an empty table.
  -- We don't want to cache an empty table because it might be created later.
  if vim.fn.hlID(hl) == 0 then
    return {}
  end

  cache[hl] = vim.api.nvim_get_hl(0, {
    name = hl,
    link = false,
    create = false,
  })

  return cache[hl]
end

function M.get_name()
  return mode_names[api.nvim_get_mode().mode] or "Normal"
end

function M.get_short_name()
  return mode_short_names[api.nvim_get_mode().mode] or "NO"
end

local function highlight()
  local turquoise = "#5de4c7"
  local pale_azure = "#89ddff"
  local lemon_chiffon = "#fffac2"
  local lavender_pink = "#fcc5e9"
  local peach = "#FAB387"

  vim.api.nvim_set_hl(0, "NormalMode", { fg = turquoise })
  vim.api.nvim_set_hl(0, "InsertMode", { fg = pale_azure })
  vim.api.nvim_set_hl(0, "VisualMode", { fg = lemon_chiffon })
  vim.api.nvim_set_hl(0, "ReplaceMode", { fg = lavender_pink })
  vim.api.nvim_set_hl(0, "TerminalMode", { fg = peach })
  vim.api.nvim_set_hl(0, "CommandMode", { fg = peach })

  vim.api.nvim_set_hl(0, "CursorLineNr", { link = "CurrentMode" })
end

function M.setup()
  local group = vim.api.nvim_create_augroup("willothy/mode", { clear = true })

  vim.schedule(function()
    vim.api.nvim_set_hl(0, "CurrentMode", M.get_color())

    highlight()

    vim.api.nvim_create_autocmd({ "ModeChanged" }, {
      group = group,
      callback = function()
        vim.api.nvim_set_hl(0, "CurrentMode", M.get_color())
      end,
    })

    vim.api.nvim_create_autocmd("ColorSchemePre", {
      group = group,
      callback = function()
        cache = {}
      end,
    })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = group,
      callback = function()
        highlight()
      end,
    })
  end)
end

return M
