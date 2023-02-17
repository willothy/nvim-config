-- NEOTREE SETUP
-- Remove legacy commands
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

vim.keymap.set("n", "<C-n>", ":NeoTreeShowToggle<CR>", { noremap = true, silent = true })

require("neo-tree").setup({
    close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,
    sort_case_insensitive = false, -- used when sorting files and directories in the tree
    container = {
        enable_character_fade = true
    },
    indent = {
        indent_size = 2,
        padding = 1, -- extra padding on left hand side
        -- indent guides
        with_markers = true,
        indent_marker = "│",
        last_indent_marker = "└",
        highlight = "NeoTreeIndentMarker",
        -- expander config, needed for nesting files
        with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
    },
    icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "ﰊ",
        -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
        -- then these will never be used.
        default = "*",
        highlight = "NeoTreeFileIcon"
    },
    modified = {
        symbol = "[+]",
        highlight = "NeoTreeModified",
    },
    name = {
        trailing_slash = false,
        use_git_status_colors = true,
        highlight = "NeoTreeFileName",
    },
    git_status = {
        symbols = {
            -- Change type
            added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
            modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
            deleted   = "✖", -- this can only be used in the git_status source
            renamed   = "", -- this can only be used in the git_status source
            -- Status type
            untracked = "",
            ignored   = "",
            unstaged  = "",
            staged    = "",
            conflict  = "",
        },
        window = {
            position = "float",
            mappings = {
                ["A"]  = "git_add_all",
                ["gu"] = "git_unstage_file",
                ["ga"] = "git_add_file",
                ["gr"] = "git_revert_file",
                ["gc"] = "git_commit",
                ["gp"] = "git_push",
                ["gg"] = "git_commit_and_push",
            }
        }
    },
    window = {
        position = "left",
        width = 10,
    },
    filesystem = {
        filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
        },
        hijack_netrw_behavior = "disabled",
        use_libuv_file_watcher = true,
        follow_current_file = true,
        group_empty_dirs = false,
    },
})
