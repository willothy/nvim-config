--local function setup()
--    local a = require("plenary.async")
--    local tx, rx = a.control.channel.oneshot()
--    local dict = require("cmp_dictionary")
--
--    local autocmd
--    autocmd = vim.api.nvim_create_autocmd("BufEnter", {
--        callback = function()
--            tx(dict)
--            a.run(function()
--               local dict = rx()
--                dict.setup()
--                dict.switcher({
--                    spelllang = {
--                        en = "/usr/share/dict/en.dict"
--                    }
--                })
--            end)
--            vim.api.nvim_del_autocmd(autocmd)
--        end
--    })
--end

local opts = {
    exact = 6,
    async = true,
    max_items = 8,
}

return { {
    'uga-rosa/cmp-dictionary',
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    event = 'VeryLazy',
    lazy = true,
    opts = opts,
    --init = setup
} }
