require("toggleterm").setup()

N_map("<leader>t", function()
    vim.cmd("ToggleTerm direction=horizontal size=15")
end)
