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

local format = require('lsp-format')
format.setup()
local inlayhints = require('lsp-inlayhints')
inlayhints.setup({
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
    mapping = cmp_mappings
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
-- local lspconfig = require('lspconfig')
-- require('mason-lspconfig').setup_handlers({
--     function(server_name)
--         lspconfig[server_name].setup({
--             on_attach = lsp_attach,
--             capabilities = lsp_capabilities,
--         })
--     end,
-- })

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

-- vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
-- vim.api.nvim_create_autocmd("LspAttach", {
--     group = "LspAttach_inlayhints",
--     callback = function(args)
--         if not (args.data and args.data.client_id) then
--             return
--         end

--         local bufnr = args.buf
--         local client = vim.lsp.get_client_by_id(args.data.client_id)
--         require("lsp-inlayhints").on_attach(client, bufnr)
--     end
-- })

-- vim.diagnostic.config({
--     virtual_text = true,
--     signs = true,
--     update_in_insert = true,
--     underline = true,
--     severity_sort = false,
--     float = true,
-- })

-- lsp.setup()
