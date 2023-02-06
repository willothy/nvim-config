-- require('nvim_comment').setup({
--     -- line_mapping = "<leader>cl",
--     -- operator_mapping = "<leader>c",
--     comment_empty = false,
-- })

require('Comment').setup({
    toggler = { -- Normal Mode
        line = '<leader>cc',
        block = '<leader>cb'
    },
    opleader = { -- Visual Mode
        block = '<leader>c',
    },
    extra = {
        eol = '<leader>l$',
    },
})
