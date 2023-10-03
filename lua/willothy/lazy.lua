return {
  setup = function()
    -- setup ui
    willothy.ui.setup()
    willothy.hydras.setup()

    require("willothy.commands")
    require("willothy.autocmds")
    require("willothy.keymap")

    -- Inform vim how to enable undercurl in wezterm
    vim.api.nvim_exec2(
      [[
let &t_Cs = "\e[4:3m"
let &t_Ce = "\e[4:0m"
    ]],
      { output = false }
    )
  end,
}
