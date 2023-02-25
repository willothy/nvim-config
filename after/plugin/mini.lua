--[[ require('mini.trailspace').setup({
    only_in_normal_buffers = true
}) ]]
-- require('mini.sessions').setup()
require('mini.jump').setup({
    -- Disable on dashboard
})
require('mini.indentscope').setup()
require('mini.cursorword').setup()

function HandleMiniDisable()
    local buf_ty = GetBufType()
    if HasValue({
        "dashboard", "netrw", "help", "toggleterm", "floaterm", "alpha"
    }, buf_ty) then
        vim.b.minicursorword_disable = true
        vim.b.miniindentscope_disable = true
        vim.b.minimap_disable = true
    else
        vim.b.minicursorword_disable = false
        vim.b.miniindentscope_disable = false
        vim.b.minimap_disable = false
    end
end

vim.api.nvim_create_autocmd("FileType", {
    callback = function() HandleMiniDisable() end
})
