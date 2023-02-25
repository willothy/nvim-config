local M = {}

local function calc_fold(line, dir)
    local offset = -1

    if dir > 0 then
        offset = vim.fn.foldclosedend(line + dir)
    else
        offset = vim.fn.foldclosed(line + dir)
    end

    return offset
end

local function countIndent(line)
    return vim.fn.indent(line) / vim.fn.shiftwidth()
end

local function indent(amount, sLine, eLine)
    local cRow = sLine or vim.api.nvim_win_get_cursor(0)[1]
    local eRow = eLine or cRow

    local cIndent = countIndent(cRow)
    local diff = amount - cIndent

    vim.cmd('silent! normal! ==')
    local newInd = countIndent(cRow)

    vim.cmd('silent! ' .. cRow .. ',' .. eRow .. string.rep('<', newInd))
    vim.cmd('silent! ' .. cRow .. ',' .. eRow .. string.rep('>', cIndent))

    if cIndent ~= newInd and diff ~= 0 then
        if cIndent < newInd then
            vim.cmd('silent! ' .. cRow .. ',' .. eRow .. string.rep('>', newInd - cIndent))
        else
            vim.cmd('silent! ' .. cRow .. ',' .. eRow .. string.rep('<', cIndent - newInd))
        end
    elseif diff > 0 then
        vim.cmd('silent! ' .. cRow .. ',' .. eRow .. string.rep('>', diff))
    end
end

local function indent_block(amount, sLine, eLine)
    local cRow = sLine or vim.api.nvim_win_get_cursor(0)[1]
    local eRow = eLine or cRow

    local cIndent = countIndent(cRow)
    local diff = amount - cIndent

    if diff < 0 then
        vim.cmd('silent! ' .. cRow .. ',' .. eRow .. string.rep('<', math.abs(diff)))
    elseif diff > 0 then
        vim.cmd('silent! ' .. cRow .. ',' .. eRow .. string.rep('>', diff))
    end
end

local function calc_indent(target, dir)
    local tCount = countIndent(target)
    local nCount = countIndent(target + dir)

    if tCount < nCount then
        return nCount
    else
        return tCount
    end
end

local function swap_line(line, target)
    local line_text = vim.fn.getline(line)
    local target_text = vim.fn.getline(target)

    vim.fn.setline(line, target_text)
    vim.fn.setline(target, line_text)
end

---@param dir number
---@return nil
function M.moveLine(dir)
    local last_line = vim.fn.line("$")

    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line = cursor_pos[1]

    if dir == nil then
        return
    end

    if line == 1 and dir < 0 then
        return
    elseif line == last_line and dir > 0 then
        return
    end

    if line >= 1 and line <= last_line then
        local target = line
        local fold = calc_fold(line, dir)

        if fold ~= -1 then
            target = fold
        end

        local amount = calc_indent(target + dir, dir)
        swap_line(line, target + dir)
        indent(amount, target + dir)
    end
end

local function get_target(sRow, eRow)
    return vim.api.nvim_buf_get_lines(0, sRow, eRow, true)
end

local function move_range(block, sRow, eRow)
    vim.api.nvim_buf_set_lines(0, sRow, eRow, true, block)
end

local function reselect_block(dir, vSRow, vERow)
    vim.api.nvim_exec(':normal! \\e\\e', false)
    vim.api.nvim_exec(
        ':normal! ' .. (dir > 0 and vSRow + 2 or vSRow) .. 'ggV' .. (vERow + dir) .. 'gg',
        false)
end

function M.moveBlock(dir, line1, line2)
    local vSRow = line1 or vim.fn.line('v')
    local vERow = line2 or vim.api.nvim_win_get_cursor(0)[1]
    local last_line = vim.fn.line("$")
    local fold_expr = vim.wo.foldexpr

    vSRow = vSRow - 1

    if vSRow > vERow then
        local aux = vSRow
        vSRow = vERow
        vERow = aux
    end

    if vSRow == 0 and dir < 0 then
        vim.api.nvim_exec(':normal!' .. vSRow .. 'ggV' .. (vERow + dir) .. 'gg', false)
        return
    end
    if vERow == last_line and dir > 0 then
        vim.api.nvim_exec(':normal!' .. (vSRow + 1) .. 'ggV' .. (vERow + dir) .. 'gg', false)
        return
    end

    local vBlock = vim.api.nvim_buf_get_lines(0, vSRow, vERow, true)

    if dir < 0 then
        local vTarget = get_target(vSRow - 1, vSRow)
        table.insert(vBlock, vTarget[1])
    elseif dir > 0 then
        local vTarget = get_target(vERow, vERow + 1)
        table.insert(vBlock, 1, vTarget[1])
    end

    local amount = calc_indent((dir > 0 and vERow or vSRow + 1) + dir, dir)
    move_range(vBlock, (dir > 0 and vSRow or vSRow - 1), (dir > 0 and vERow + 1 or vERow))

    if fold_expr == 'nvim_treesitter#foldexpr()' then
        vim.cmd(':normal! zx')
    end

    indent_block(amount, (dir > 0 and vSRow + 2 or vSRow), vERow + dir)
    reselect_block(dir, vSRow, vERow)
end

-- test
--
-- test3
--
-- test 2
--
vim.keymap.set("n", "<M-j>", Wrap(M.moveLine, 1))
vim.keymap.set("n", "<M-k>", Wrap(M.moveLine, -1))
-- vim.keymap.set("v", "<M-j>", Wrap(M.moveBlock, 1))
-- vim.keymap.set("v", "<M-k>", Wrap(M.moveBlock, -1))

return M
