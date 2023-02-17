local function split(str, sep)
    local t = {}
    for s in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, s)
    end
    return t
end


local M = {}

local default_options = {
    icons = {
        File = " ",
        Module = " ",
        Namespace = " ",
        Package = " ",
        Class = " ",
        Method = " ",
        Property = " ",
        Field = " ",
        Constructor = " ",
        Enum = " ",
        Interface = " ",
        Function = " ",
        Variable = " ",
        Constant = " ",
        String = " ",
        Number = " ",
        Boolean = " ",
        Array = " ",
        Object = " ",
        Key = " ",
        Null = " ",
        EnumMember = " ",
        Struct = " ",
        Event = " ",
        Operator = " ",
        TypeParameter = " ",
    },
    padding = 1,
    separator = "  ",
    web_dev_icons = true,
    create_autocmd = true,
    setup_navic = true,
}

function M.setup(opt)
    M.options = vim.tbl_deep_extend("force", default_options, opt or {})
    require('nvim-navic').setup({
        icons = M.options.icons,
        highlight = false,
        depth_limit = 0,
        depth_limit_indicator = "..",
        safe_output = true,
    })
    require('nvim-lspconfig')
end

function M.build_winbar(args)
    local winbar = ""
    local padding = string.rep(" ", M.options.padding)
    local separator = M.options.separator
    local icons = M.options.icons
    local use_web_devicons = M.options.web_dev_icons
end

return M
