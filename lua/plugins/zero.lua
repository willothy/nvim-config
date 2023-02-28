local function lspzero()
    local lsp = require('lsp-zero')
    lsp.preset({
        name = 'recommended',
        set_lsp_keymaps = true,
        manage_nvim_cmp = false,
        suggest_lsp_servers = true,
    })

    lsp.on_attach(function(client, bufnr)
        local opts = { buffer = bufnr, remap = false }

        local format = require('lsp-format')
        format.setup()
        format.on_attach(client)

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
                label_formatter = function(labels, kind, opts, client_name)
                    return table.concat(labels or {}, "")
                end,
                virt_text_formatter = function(label, hint, opts, client_name)
                    if client_name == "lua_ls" then
                        if hint.kind == 2 then
                            hint.paddingLeft = false
                        else
                            hint.paddingRight = false
                        end
                    end

                    local virt_text = {}
                    virt_text[#virt_text + 1] = hint.paddingLeft and { " ", "Normal" } or nil
                    virt_text[#virt_text + 1] = { label, opts.highlight }
                    virt_text[#virt_text + 1] = hint.paddingRight and { " ", "Normal" } or nil

                    return virt_text
                end,
                highlight = "LspInlayHint",
                --priority = 0,
            },
            enabled_at_startup = true,
        })
        inlayhints.on_attach(client, bufnr)

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>hs", vim.lsp.buf.signature_help, opts)
    end)

    vim.api.nvim_exec([[
nmenu PopUp.Show\\ References   :lua vim.lsp.buf.references()
nmenu PopUp.Goto\\ Definition   :lua vim.lsp.buf.definition()
nmenu PopUp.Goto\\ Declaration  :lua vim.lsp.buf.declaration()
nmenu PopUp.Code\\ Actions      :lua vim.lsp.buf.code_action()
nmenu PopUp.Rename              :lua vim.lsp.buf.rename()<CR>")
nmenu PopUp.Signature\\ Help    :lua vim.lsp.buf.signature_help()
]], true)

    lsp.configure('bash-language-server', {
        settings = {
            bashIde = {
                includeAllWorkspaceSymbols = true
            }
        }
    })

    lsp.configure('rust_analyzer', {
        settings = {
            ["rust-analyzer"] = {
                assist = {
                    importGranularity = "module",
                    importPrefix = "by_self",
                },
                cargo = {
                    loadOutDirsFromCheck = true,
                },
                procMacro = {
                    enable = true,
                },
                imports = {
                    prefix = "self",
                },
                inlayHints = {
                    render_colons = true,
                    type_hints = true,
                    parameter_hints = true,
                    chaining_hints = true,
                    hide_closure_initialization_hints = false,
                    adjustment_hints = {
                        enable = "always",
                    },
                    discriminant_hints = {
                        enable = "always",
                    },
                    lifetimeElisionHints = {
                        enable = "always",
                        useParemeterNames = true
                    },
                    closureReturnTypeHints = {
                        enable = "always"
                    },
                    discriminantHints = {
                        enable = "fieldless"
                    },
                    bindingModeHints = {
                        enable = true
                    }
                },
                lens = {
                    run = true,
                    enable = true,
                    implementations = {
                        enable = true
                    },
                    method_refs = {
                        enable = true
                    },
                    references = {
                        adt = {
                            enable = true
                        },
                        enumVariant = {
                            enable = true
                        },
                        method = {
                            enable = true
                        },
                        trait = {
                            enable = true
                        },
                    }
                },
                hover = {
                    actions = {
                        references = {
                            enable = true
                        }
                    }
                }
            },
        },
    })
    lsp.setup()

    vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        update_in_insert = true,
        underline = true,
        severity_sort = true,
        float = true,
    })
end

local aerial_opt = {
    dense = true,
    depth = 5
}

local function aerial_cfg()
    vim.keymap.set("n", "<leader>o", function()
        require('aerial').toggle()
    end)
end

local fidget = {
    text = {
        spinner = "dots",
        done = "✓",
        commenced = "",
        completed = "✓",
    },
    window = {
        blend = 0
    }
}

local function inc_rename()
    vim.keymap.set("n", "<leader>rn", function()
        return ":IncRename " .. vim.fn.expand("<cword>")
    end, { expr = true })
end

local neodev = {
    plugins = { "willothy" }
}

return {
    {
        'VonHeikemen/lsp-zero.nvim',
        dependencies = {
            'neovim/nvim-lspconfig',
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',

            -- Config dependencies
            'lvimuser/lsp-inlayhints.nvim',
            'lukas-reineke/lsp-format.nvim',
            'SmiteshP/nvim-navic',
            'utilyre/barbecue.nvim',
        },
        init = lspzero,
        lazy = true,
        config = true,
        event = 'VeryLazy',
    },
    {
        'stevearc/aerial.nvim',
        opts = aerial_opt,
        init = aerial_cfg,
        config = true,
        event = 'VeryLazy',
    },
    {
        'folke/neodev.nvim',
        lazy = true,
        opts = neodev,
        config = true,
        event = 'VeryLazy',
    },
    {
        'j-hui/fidget.nvim',
        opts = fidget,
        lazy = true,
        event = 'VeryLazy',
        config = true,
    },
    {
        'smjonas/inc-rename.nvim',
        init = inc_rename,
        config = true,
        event = 'VeryLazy',
    },
    {
        'lvimuser/lsp-inlayhints.nvim',
        branch = "anticonceal",
        lazy = true,
        event = 'VeryLazy',
    },
    {
        'williamboman/mason.nvim',
        lazy = true,
        event = 'VeryLazy',
    }
}
