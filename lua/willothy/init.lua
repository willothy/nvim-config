function GetBufType()
    return vim.bo.filetype
end

function HasValue(arr, val)
    for index, value in ipairs(arr) do
        if value == val then
            return true
        end
    end
    return false
end

function Highlight(mode, group, opt)
    vim.api.nvim_set_hl(mode, group, opt)
end

function SetupColor(color)
    color = color or "snazzy"
    vim.cmd.colorscheme(color)

    --vim.opt.background = "dark"
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

    Highlight(0, "Normal", { bg = "none" })
    Highlight(0, "Constant", { bg = "none" })
    Highlight(0, "Special", { bg = "none" })
    Highlight(0, "LineNr", { bg = "none" })

    Highlight(0, "EnfOfBuffer", { bg = "none" })

    Highlight(0, "NonText", { bg = "none" })
    Highlight(0, "NormalFloat", { bg = "none" })
end

SetupColor()

require('willothy.packer')
require("willothy.remap")
require("willothy.set")
