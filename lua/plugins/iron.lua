local opt = function()
    local view = require("iron.view")
    return {
        config = {
            scratch_repl = true,
            repl_definition = {
                sh = {
                    command = { "bash" }
                },
                alpha = {
                    command = { "bash" }
                },
                python = {
                    command = { "python3" }
                },
                node = {
                    command = { "node" }
                },
                ["."] = {
                    command = { "bash" }
                },
            },
            repl_open_cmd = view.offset({
                width = "30%",
                height = 20,
                w_offset = "70%",
                h_offset = "5%",
            }),
            keymaps = {
                exit = "<space>qq",
                clear = "<space>cl",
            },
            ignore_blank_lines = true,
        }
    }
end

local function setup()
    -- vim.keymap.set('n', '<leader>rs', function()
    --     vim.api.nvim_exec("IronRepl sh", true)
    -- end)
    -- vim.keymap.set('n', '<leader>rr', function()
    --     vim.api.nvim_exec("IronRestart", true)
    -- end)
    vim.keymap.set('n', '<leader>rf', function()
        vim.api.nvim_exec("IronFocus", true)
    end)
    vim.keymap.set('n', '<leader>rh', function()
        vim.api.nvim_exec("IronHide", true)
    end)
end

return { {
    'hkupty/iron.nvim',
    event = 'VeryLazy',
    lazy = true,
    opts = opt,
    config = function(_, opts)
        require("iron.core").setup(opts)
    end,
    init = setup,
} }
