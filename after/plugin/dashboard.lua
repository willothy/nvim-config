local home = os.getenv('HOME')
local api = vim.api
local icons = require('nvim-web-devicons')
local alpha = require('alpha')

local if_nil = vim.F.if_nil

local default_terminal = {
    type = "terminal",
    command = nil,
    width = 69,
    height = 8,
    opts = {
        redraw = true,
        window_config = {},
    },
}

local default_header = {
    type = "text",
    val = {
        '███▄    █ ▓█████  ▒█████   ██▒   █▓ ██▓ ███▄ ▄███▓ ',
        '██ ▀█   █ ▓█   ▀ ▒██▒  ██▒▓██░   █▒▓██▒▓██▒▀█▀ ██▒ ',
        '▓██  ▀█ ██▒▒███   ▒██░  ██▒ ▓██  █▒░▒██▒▓██    ▓██░',
        '▓██▒  ▐▌██▒▒▓█  ▄ ▒██   ██░  ▒██ █░░░██░▒██    ▒██ ',
        '▒██░   ▓██░░▒████▒░ ████▓▒░   ▒▀█░  ░██░▒██▒   ░██▒',
        '░ ▒░   ▒ ▒ ░░ ▒░ ░░ ▒░▒░▒░    ░ ▐░  ░▓  ░ ▒░   ░  ░',
        '░ ░░   ░ ▒░ ░ ░  ░  ░ ▒ ▒░    ░ ░░   ▒ ░░  ░      ░',
        '░   ░ ░    ░   ░ ░ ░ ▒       ░░   ▒ ░░      ░      ',
        '░    ░  ░    ░ ░        ░   ░         ░            ',
        '░                                                  ',
    },
    opts = {
        position = "center",
        hl = "Type",
        -- wrap = "overflow";
    },
}

local footer = {
    type = "text",
    val = "",
    opts = {
        position = "center",
        hl = "Number",
    },
}

local leader = "SPC"

--- @param sc string
--- @param txt string
--- @param keybind string? optional
--- @param keybind_opts table? optional
local function button(sc, txt, keybind, keybind_opts)
    local sc_ = sc:gsub("%s", ""):gsub(leader, "<leader>")

    local opts = {
        position = "center",
        shortcut = sc,
        cursor = 5,
        width = 50,
        align_shortcut = "right",
        hl_shortcut = "Keyword",
    }
    if keybind then
        keybind_opts = if_nil(keybind_opts, { noremap = true, silent = true, nowait = true })
        opts.keymap = { "n", sc_, keybind, keybind_opts }
    end

    local function on_press()
        local key = vim.api.nvim_replace_termcodes(keybind or sc_ .. "<Ignore>", true, false, true)
        vim.api.nvim_feedkeys(key, "t", false)
    end

    return {
        type = "button",
        val = txt,
        on_press = on_press,
        opts = opts,
    }
end

local buttons = {
    type = "group",
    val = {
        button("f", "  New file", "<leader>fn"),
        button("l", "  Open last session", "<leader>ll"), -- session load
        button("s", "  Past sessions", "<leader>ls"),
        button("q", "  Find file", "<leader>ff"), -- fuzzy find
        button("w", "  Projects", "<leader>pf"), -- open projects folder
        button("r", "  Recently opened files", "<cmd>lua require('telescope.builtin').oldfiles()<CR>"),
        button("u", "  Update plugins", "<cmd>PackerSync<CR>"),
        button("c", "  Edit neovim config", "<leader>nv"),
    },
    opts = {
        spacing = 1,
    },
}

local section = {
    terminal = default_terminal,
    header = default_header,
    buttons = buttons,
    footer = footer,
}

local config = {
    layout = {
        { type = "padding", val = 2 },
        section.header,
        { type = "padding", val = 2 },
        section.buttons,
        section.footer,
    },
    opts = {
        margin = 5,
    },
}

local theme = {
    button = button,
    section = section,
    config = config,
    -- theme config
    leader = leader,
    -- deprecated
    opts = config,
}

alpha.setup(theme.config)

vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#5089fa", bg = "none" })
vim.api.nvim_set_hl(0, "DashboardFooter", { fg = "#5089fa", bg = "none" })
vim.api.nvim_set_hl(0, "DashboardDesc", { bg = "none" })
vim.api.nvim_set_hl(0, "DashboardKey", { bg = "none" })
vim.api.nvim_set_hl(0, "DashboardIcon", { bg = "none" })
vim.api.nvim_set_hl(0, "DashboardShotCut", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuf", { bg = "none" })
vim.api.nvim_set_hl(0, "NonText", { bg = "none" })

local dashboard_start = api.nvim_create_augroup('dashboard_start', { clear = true })

local ft = function()
    if db.hide_statusline then
        vim.opt.laststatus = 0
    end

    if db.hide_tabline then
        vim.opt.showtabline = 0
    end

    if vim.fn.has('nvim-0.8') == 1 then
        if db.hide_winbar then
            vim.opt.winbar = ''
        end
    end
end

api.nvim_create_autocmd('FileType', {
    group = dashboard_start,
    pattern = 'dashboard',
    callback = ft,
})

local function get_listed_buffers()
    local buffers = {}
    local len = 0
    for buffer = 1, vim.fn.bufnr('$') do
        if vim.fn.buflisted(buffer) == 1 then
            len = len + 1
            buffers[len] = buffer
        end
    end

    return buffers
end

vim.api.nvim_create_augroup('alpha_on_empty', { clear = true })
vim.api.nvim_create_autocmd("User", {
    pattern = "BDeletePost*",
    group = "alpha_on_empty",
    callback = function(event)
        local fallback_name = vim.api.nvim_buf_get_name(event.buf)
        local fallback_ft = vim.api.nvim_buf_get_option(event.buf, "filetype")
        local fallback_on_empty = fallback_name == "" and fallback_ft == ""

        if fallback_on_empty then
            vim.cmd("Alpha")
        end
    end,
})

api.nvim_create_user_command('Bd', function()
    require('bufdelete').bufdelete(0, true)
end, {})

api.nvim_create_user_command('Projects', function()
    api.nvim_set_current_dir("~/Projects")
    vim.cmd.Ex()
end, {})

vim.keymap.set("n", "<leader>fn", ":enew<CR>")
vim.keymap.set("n", "<leader>ls", ":SessionManager load_session<CR>")
vim.keymap.set("n", "<leader>ll", ":SessionManager load_last_session<CR>")
vim.keymap.set("n", "<leader>ss", ":SessionManager save_current_session<CR>")
vim.keymap.set("n", "<leader>pf", ":Projects<CR>")
vim.keymap.set("n", "<leader>nv", ":edit ~/.config/nvim/<CR>")
vim.keymap.set("n", "<leader>D", ":Alpha<CR>")
