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

require("willothy.remap")
require("willothy.set")
require('willothy.lazy')
