function Highlight(mode, group, opt)
    vim.api.nvim_set_hl(mode, group, opt)
end

require("catppuccin").setup({
    transparent_background = true,
    term_colors = true,
    styles = {
        comments = {}
    },
    integrations = {
        cmp = true,
        gitsigns = true,
        telescope = true,
        notify = true,
        mini = true,
        fidget = true,
        harpoon = true,
        mason = true,
        noice = true,
        neotree = true,
        treesitter = true,
        lsp_trouble = true,
        native_lsp = {
            enabled = true,
            virtual_text = {
                errors = {},
                hints = { "italic" },
                warnings = {},
                information = {}
            },
            underlines = {
                errors = {},
                hints = {},
                warnings = {},
                information = {}
            }
        }
    }
})

function SetupColor(color)
    color = color or "catppuccin"

    vim.g.transparent_enabled = true
    vim.cmd.colorscheme(color)
    Highlight(0, 'SignColumn', { bg = "none" })
    Highlight(0, 'DiffAdd', { bg = "none" })
    Highlight(0, 'DiffDelete', { bg = "none" })
    Highlight(0, 'DiffChange', { bg = "none" })
    Highlight(0, 'SignifyLineChange', { bg = "none" })
    Highlight(0, 'SignifyLineDelete', { bg = "none" })
    Highlight(0, 'TabLine', { bg = "none" })
    Highlight(0, 'TabLineSel', { bg = "none", underline = true })

    Highlight(0, 'LspInlayHint', {
        fg = "#9294a0", bg = "none", italic = true
    })

    Highlight(0, 'Comment', { fg = "#a6accd", bg = "none", italic = false })

    Highlight(0, "Normal", { bg = "none" })
    Highlight(0, "Constant", { bg = "none" })
    Highlight(0, "Special", { bg = "none" })
    Highlight(0, "LineNr", { bg = "none" })

    Highlight(0, "EnfOfBuffer", { bg = "none" })

    Highlight(0, "NonText", { bg = "none" })
    Highlight(0, "NormalFloat", { bg = "none" })
end

SetupColor()

require("barbecue").setup({
    attach_navic = true,
    theme = "catppuccin",
})
