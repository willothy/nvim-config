require("toggleterm").setup({
  start_in_insert = true,
  winbar = {
    enabled = false,
    name_formatter = function(term)
      local id = term.name:sub(-1)
      local shellpath, _name = unpack(vim.split(term.name, ";"))
      local shell = vim.split(shellpath, "/")
      local hl = "%#ToggleTermName#"
      return hl .. id .. " • " .. (term.display_name or shell[#shell])
    end,
  },
})
