local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.ensure_installed({
    'tsserver',
    'eslint',
    'sumneko_lua',
    'rust_analyzer'
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
})

vim.api.nvim_set_hl(0, 'LspInlayHint', {
    fg = "#9294a0", bg = "#282a36", italic = true
})

require("lsp-inlayhints").setup({
    inlay_hints = {
        parameter_hints = {
            show = true,
            separator = '',
            remove_colon_start = true,
            remove_colon_end = true,
        },
        type_hints = {
            show = true,
            separator = '',
            remove_colon_start = true,
            remove_colon_end = true,
        }
    }
})

local format = require('lsp-format')
format.setup()

lsp.set_preferences({
    sign_icons = {}
})

lsp.setup_nvim_cmp({
    mapping = cmp_mappings
})

function EnsureLSPSetup()
    vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        update_in_insert = true,
        underline = true,
        severity_sort = false,
        float = true,
    })

    local lsp = require('lsp-zero')

    lsp.on_attach(function(client, bufnr)
        local opts = { buffer = bufnr, remap = false }
        require('lsp-inlayhints').on_attach(client, bufnr)
        format.on_attach(client)
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("n", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    end)

    lsp.setup()
end

EnsureLSPSetup()

vim.api.nvim_create_autocmd("FileType", {
    callback = function() EnsureLSPSetup() end
})
