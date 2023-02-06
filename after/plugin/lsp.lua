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
    ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.confirm({ select = false }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.config.disable,
    ['<S-Tab>'] = cmp.config.disable
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(), -- important!
    sources = {
        { name = 'nvim_lua' },
        { name = 'cmdline' },
    },
})
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(), -- important!
    sources = {
        { name = 'buffer' },
    },
})

local format = require('lsp-format')
format.setup()
local inlayhints = require('lsp-inlayhints')
inlayhints.setup({
    inlay_hints = {
        parameter_hints = {
            show = true,
            separator = ', ',
            remove_colon_start = true,
            remove_colon_end = true,
        },
        type_hints = {
            show = true,
            separator = ', ',
            remove_colon_start = true,
            remove_colon_end = true,
        },
        highlight = "LspInlayHint",
        priority = 0,
    },
    enabled_at_startup = true,
})

lsp.set_preferences({
    sign_icons = {}
})

lsp.setup_nvim_cmp({
    mapping = cmp_mappings,
    completion = {
        autocomplete = false,
    }
})

lsp.nvim_workspace()

local lsp_attach = function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    inlayhints.on_attach(client, bufnr)
    format.on_attach(client)

    --require("lsp-inlayhints").on_attach(client, bufnr)
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
end
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

lsp.on_attach(lsp_attach)

lsp.setup()

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    update_in_insert = false,
    underline = true,
    severity_sort = false,
    float = true,
})
