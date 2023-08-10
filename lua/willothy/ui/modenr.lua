local Modenr = {}

function Modenr.setup()
  local api = vim.api
  local function mode_name()
    local mode = api.nvim_get_mode().mode
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
    local mode = mode_name()
    local hl = api.nvim_get_hl(0, { name = mode .. "Mode", link = false })
    api.nvim_set_hl(0, "CursorLineNr", hl)
  end
  update_mode()

  local group = api.nvim_create_augroup("Modenr", { clear = true })
  api.nvim_create_autocmd("ModeChanged", {
    group = group,
    callback = update_mode,
  })
end

return Modenr
