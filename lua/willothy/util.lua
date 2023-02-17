function Browse(target)
    if target == nil then
        target = vim.fn.getcwd()
    elseif type(target) == 'function' then
        target = target()
    end
    require('telescope').extensions.file_browser.file_browser({ cwd = target })
end

vim.api.nvim_create_user_command('Browse', function(args)
    local target
    if args and args["args"] then
        target = args["args"]
    else
        target = vim.fn.getcwd()
    end
    require('telescope').extensions.file_browser.file_browser({ cwd = target })
end, { nargs = "?" })

function Wrap(fn, ...)
    local arg = ...
    return function()
        return fn(arg)
    end
end

function GetParentPath(path)
    pattern1 = "^(.+)//"
    pattern2 = "^(.+)\\"

    if (string.match(path, pattern1) == nil) then
        return string.match(path, pattern2)
    else
        return string.match(path, pattern1)
    end
end
