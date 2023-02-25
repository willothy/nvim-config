vim.api.nvim_create_augroup("TempBuf", { clear = true })

local function round(float)
    return math.floor(float + 0.5)
end

local ui = vim.api.nvim_list_uis()[1]

---@alias buffer integer
---@alias window integer

-- Configures a window
---@param conf table
local function window_config(conf)
    local col
    local row

    if type(conf.col) == 'string' then
        if conf.col == "left" then
            col = 0
        elseif conf.col == "right" then
            col = ui.width - conf.width
        else
            col = (ui.width - conf.width) / 2
        end
    elseif type(conf.col) == 'number' then
        col = conf.col
    else
        col = (ui.width - conf.width) / 2
    end

    if type(conf.row) == 'string' then
        if conf.row == "top" then
            row = 0
        elseif conf.row == "bottom" then
            row = ui.height - conf.height
        else
            row = (ui.height - conf.height) / 2
        end
    elseif type(conf.row) == 'number' then
        row = conf.row
    else
        row = (ui.height - conf.height) / 2
    end

    return {
        relative = conf.relative or "editor",
        width = conf.width,
        height = conf.height,
        col = col,
        row = row,
        focusable = conf.focusable ~= nil and conf.focusable or true,
        style = "minimal",
        border = "single"
    }
end

-- Opens a window with the given buffer
---@param bufnr number
---@param enter boolean
---@param config table
function OpenWin(bufnr, enter, config)
    if type(enter) == 'table' then
        config = enter
        enter = false
    end
    local window = vim.api.nvim_open_win(bufnr, enter, config)
    local autocmd
    autocmd = vim.api.nvim_create_autocmd("WinLeave", {
        group = "TempBuf",
        buffer = bufnr,
        callback = function()
            vim.api.nvim_win_close(window, true)
            vim.api.nvim_del_autocmd(autocmd)
        end
    })
    return window
end

---@param bufnr number
---@param row number | string | nil
---@param col number | string | nil
---@param width number | nil
---@param height number | nil
function WindowPopup(bufnr, row, col, width, height)
    if type(width) == 'string' then
        width = round(ui.width * (width:gsub("%%", "") / 100))
    elseif type(width) == 'number' then
        width = round(ui.width * (width / 100))
    else
        vim.notify(
            string.format("Could not open window: width is %s, expected percentage string or number", type(width)),
            "error")
        return
    end

    if type(height) == 'string' then
        height = round(ui.height * (height:gsub("%%", "") / 100))
    elseif type(height) == 'number' then
        height = round(ui.height * (height / 100))
    else
        vim.notify(
            string.format("Could not open window: height is %s, expected percentage string or number", type(height)),
            "error")
        return
    end
    width = width or round(ui.width * 0.25)
    height = height or round(ui.height * 0.25)
    local conf = window_config({
        width = width,
        height = height,
        col = col or ((ui.width - width) / 2),
        row = row or ((ui.height - height) / 2),
    })
    OpenWin(bufnr, true, conf)
end

---@param bufnr number
function CursorPopup(bufnr)
    local conf = window_config({
        width = 10,
        height = 5,
        row = 0,
        col = 0,
        relative = "cursor"
    })
    OpenWin(bufnr, true, conf)
end

-- Creates a temporary buffer with the given string or lines
---@param contents string | table
---@return integer|buffer
function TempBufWith(contents)
    local bufnr = vim.api.nvim_create_buf(true, false)
    local lines = {}
    if type(contents) == 'table' then
        lines = contents
    else
        for line in contents:gmatch("([^\n]*)\n?") do
            table.insert(lines, line)
        end
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
    vim.api.nvim_create_autocmd("BufLeave", {
        group = "TempBuf",
        buffer = bufnr,
        callback = function()
            vim.api.nvim_buf_delete(bufnr, { force = true })
            --buffer_number = -1
        end
    })
    return bufnr
end

-- Gets LSP info and displays it in a temporary buffer
---@return nil
function GetLSPInfo()
    local lsp = vim.inspect(vim.lsp.get_active_clients())
    local lines = {}
    for line in lsp:gmatch("([^\n]*)\n?") do
        table.insert(lines, line)
    end
    WindowPopup(TempBufWith(lines), "top", "center", "70%", "70%")
end

local M = {}

local blame_ns = vim.api.nvim_create_namespace("blame")

function M.add_virtual_text(text)
    local bufnr = vim.api.nvim_get_current_buf()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))

    local opts = {
        end_line = line,
        id = 1,
        virt_text = { { text, "Comment" } },
        virt_text_pos = "eol",
        --virt_text_win_col = 0
    }
    M.mark = vim.api.nvim_buf_set_extmark(bufnr, blame_ns, line - 1, col, opts)
end

function M.remove_virtual_text()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_del_extmark(bufnr, blame_ns, M.mark)
end

return M
