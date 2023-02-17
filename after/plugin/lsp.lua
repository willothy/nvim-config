local lsp = require('lsp-zero')
lsp.preset({
    name = 'recommended',
    set_lsp_keymaps = true,
    manage_nvim_cmp = false,
    suggest_lsp_servers = true,
})

lsp.ensure_installed({
    'tsserver',
    'eslint',
    'lua_ls',
    'rust_analyzer'
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
        priority = 0,
    },
    enabled_at_startup = true,
})

lsp.set_preferences({
    sign_icons = {}
})

local lsp_attach = function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    inlayhints.on_attach(client, bufnr)
    format.on_attach(client)

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("n", "<leader>hs", function() vim.lsp.buf.signature_help() end, opts)
end


lsp.on_attach(lsp_attach)

lsp.configure('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" }
            }
        }
    }
})

lsp.configure('rust_analyzer', {
    settings = {
        ["rust-analyzer"] = {
            imports = {
                prefix = "self",
            },
            inlayHints = {
                lifetimeElisionHints = {
                    enable = "skip_trivial",
                    useParemeterNames = true
                },
                closureReturnTypeHints = {
                    enable = "with_block"
                },
                discriminantHints = {
                    enable = "fieldless"
                },
                bindingModeHints = {
                    enable = true
                }
            },
            lens = {
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
