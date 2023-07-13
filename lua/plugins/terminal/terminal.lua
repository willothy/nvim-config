local function split(str, c)
  local fields = {}
  for field in str:gmatch("([^" .. c .. "]+)") do
    fields[#fields + 1] = field
  end
  return fields
end

return {
  {
    -- terminal
    "akinsho/toggleterm.nvim",
    lazy = true,
    config = function()
      require("toggleterm").setup({
        start_in_insert = true,
        winbar = {
          enabled = false,
          name_formatter = function(term)
            local id = term.name:sub(-1)
            local shellpath, _name = unpack(split(term.name, ";"))
            local shell = split(shellpath, "/")
            local hl = "%#ToggleTermName#"
            return hl .. id .. " • " .. (term.display_name or shell[#shell])
          end,
        },
      })
    end,
  },
  {
    "NvChad/nvterm",
    config = true,
    enabled = false,
  },
}
