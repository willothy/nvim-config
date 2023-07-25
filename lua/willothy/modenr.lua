local api = vim.api

local function mode_name(mode)
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
  return mode_names[mode] or "Normal"
end

local function update_mode()
  local mode = mode_name(api.nvim_get_mode().mode)
  local hl = vim.api.nvim_get_hl(0, { name = mode .. "Mode", link = false })
  vim.api.nvim_set_hl(0, "CursorLineNr", hl)
end

local function create_autocmds()
  local group = api.nvim_create_augroup("Modenr", {})
  api.nvim_create_autocmd("ModeChanged", {
    group = group,
    callback = update_mode,
  })
end

update_mode()
create_autocmds()
