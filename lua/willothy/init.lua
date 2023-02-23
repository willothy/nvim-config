function GetBufType()
    return vim.bo.filetype
end

function HasValue(arr, val)
    for _, value in ipairs(arr) do
        if value == val then
            return true
        end
    end
    return false
end

require("willothy.util")
require("willothy.remap")
require("willothy.set")
require('willothy.lazy')
require("willothy.ui")

local moveline = require("moveline")


vim.keymap.set("n", "<M-j>", moveline.move_line_down)
vim.keymap.set("n", "<M-k>", moveline.move_line_up)
--require('willothy.move')
