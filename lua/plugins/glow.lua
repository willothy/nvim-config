return { {
    "ellisonleao/glow.nvim",
    config = function()
        require("glow").setup({
            install_path = "~/go/bin"
        })
    end,
    lazy = true,
    event = "VeryLazy"
} }
