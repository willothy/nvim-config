local opt = {
    auto_update = true,
    neovim_image_text = "Neovim",
}

return {{
    -- Discord rich presence (for the lols)
    'andweeb/presence.nvim',
    event = "VeryLazy",
    lazy = true,
    opts = opt
}}
