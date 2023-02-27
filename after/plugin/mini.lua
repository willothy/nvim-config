require('mini.jump').setup({
    -- Disable on dashboard
})
require('mini.indentscope').setup()
require('mini.cursorword').setup()

function HandleMiniDisable()
    local bufinfo = vim.fn.getbufinfo(vim.api.nvim_win_get_buf(0))
    if bufinfo == nil then
        return
    end
    local buf = bufinfo[0] or bufinfo[1]
    if buf == nil then
        return
    end

    local listed = buf.listed
    if listed == 0 then
        vim.b.minicursorword_disable = true
        vim.b.miniindentscope_disable = true
    else
        vim.b.minicursorword_disable = false
        vim.b.miniindentscope_disable = false
    end
end

vim.api.nvim_create_autocmd("FileType", {
    callback = function() HandleMiniDisable() end
})
