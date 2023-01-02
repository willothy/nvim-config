n_map("<leader>t", function()
    vim.cmd("FloatermNew")
end)

n_map("<C-t>", function()
    vim.cmd("FloatermNew")
end)

t_map("<C-t>", function()
    vim.cmd("FloatermKill")
end)
