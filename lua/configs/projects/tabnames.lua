local tabnames = require("tabnames")

local function short_cwd(tabnr)
  local cwd = vim.fn.getcwd(-1, tabnr)

  cwd = vim.fn.fnamemodify(cwd, ":~")

  return cwd
end

tabnames.setup({
  auto_suggest_names = true,
  default_tab_name = function(tabnr)
    return tabnames.presets.special_tabs(tabnr)
      or tabnames.presets.special_buffers(tabnr)
      or short_cwd(tabnr)
  end,
  update_default_tab_name = {
    "TabNew",
    "TabEnter",
    "BufEnter",
    "DirChanged",
    "LspAttach",
  },
  experimental = {
    session_support = true,
  },
})
