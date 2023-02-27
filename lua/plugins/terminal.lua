local function setup()
    vim.keymap.set("n", "<leader>t", function()
        -- require("toggleterm").toggle()
        vim.api.nvim_exec("ToggleTerm direction=horizontal size=15", true)
    end)
end

return { {
    -- terminal
    "akinsho/toggleterm.nvim",
    -- config = true,
    init = setup,
    config = function()
        require("toggleterm").setup()
    end,
} }
