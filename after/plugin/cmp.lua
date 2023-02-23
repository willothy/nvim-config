local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

require('copilot').setup({
    suggestion = {
        auto_trigger = true,
        keymap = {},
    }
})
local suggestion = require('copilot.suggestion')


local luasnip = require('luasnip')
cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end
    },
    mapping = {
        ['<M-k>'] = cmp.mapping(cmp.mapping.select_prev_item(cmp_select), { "i", "c", }),
        ['<M-j>'] = cmp.mapping(cmp.mapping.select_next_item(cmp_select), { "i", "c" }),
        ['<M-Up>'] = cmp.mapping(cmp.mapping.select_prev_item(cmp.select), { "i", "c" }),
        ['<M-Down>'] = cmp.mapping(cmp.mapping.select_next_item(cmp.select), { "i", "c" }),
        ['<C-PageUp>'] = cmp.mapping(cmp.mapping.scroll_docs( -4), { "i", "c" }),
        ['<C-PageDown>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        ['<C-e>'] = cmp.mapping(cmp.mapping.abort(), { "i", "c" }),
        ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.mapping.confirm({ select = true })
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
                -- elseif suggestion.is_visible() then
                --     suggestion.accept_line()
            else
                fallback()
            end
        end, { "i", "c" }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.confirm({ select = true })
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif suggestion.is_visible() then
                suggestion.accept()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "c" }),

    },
    sources = cmp.config.sources({
        { name = 'nvim_lua' },
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        -- { name = 'buffer' },
        { name = 'path' },
    }),
    completion = {
        autocomplete = true
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
