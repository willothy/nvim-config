local Hydra = require("willothy.modules.hydras").Hydra
local diagram = Hydra({
  name = "Draw Diagram",
  hint = [[
 Arrow^^^^^^   Select region with <C-v> 
 ^ ^ _K_ ^ ^   _f_: surround it with box
 _H_ ^ ^ _L_
 ^ ^ _J_ ^ ^                      _<Esc>_
]],
  config = {
    color = "pink",
    invoke_on_body = false,
    hint = {
      border = "rounded",
      position = "bottom-left",
    },
    on_enter = function()
      vim.o.virtualedit = "all"
    end,
    on_exit = function()
      vim.o.virtualedit = "block"
    end,
  },
  mode = "n",
  heads = {
    { "H", "<C-v>h:VBox<CR>" },
    { "J", "<C-v>j:VBox<CR>" },
    { "K", "<C-v>k:VBox<CR>" },
    { "L", "<C-v>l:VBox<CR>" },
    { "f", ":VBox<CR>", { mode = "v" } },
    { "<Esc>", nil, { exit = true } },
  },
})

vim.api.nvim_create_user_command("DrawDiagram", function()
  diagram:activate()
end, {})

return diagram
