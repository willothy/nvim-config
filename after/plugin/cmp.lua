local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local luasnip = require('luasnip')
cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end
    },
    mapping = {
        ['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item(cmp_select), { "i", "c", }),
        ['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item(cmp_select), { "i", "c" }),
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        ['<C-e>'] = cmp.mapping(cmp.mapping.abort(), { "i", "c" }),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.confirm({ select = true })
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                --fallback()
            end
        end, { "c" }),
    },
    sources = cmp.config.sources({
        { name = 'nvim_lua' },
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
    }),
    completion = {
        autocomplete = false
    }
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline({
        ['<S-Tab>'] = cmp.config.disable
    }), -- important!
    sources = cmp.config.sources({
        { name = 'path' }
    },
        {
            { name = 'cmdline' },
        }),
})

cmp.setup.cmdline({ '/', '?' }, {
    --mapping = cmp.mapping.preset.cmdline(), -- important!
    sources = {
        { name = 'buffer' },
    },
})
