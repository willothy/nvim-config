local telescope = require('telescope')
local builtin = require('telescope.builtin')
local fb_actions = telescope.extensions.file_browser.actions
local fb_utils = require('telescope._extensions.file_browser.utils')

local function get_filename(path)
    local start, _ = path:find('[%w%s!-={-|]+[_%.].+')
    return path:sub(start, #path)
end

local function add_selected_to_harpoon(prompt_bufnr)
    local files = fb_utils.get_selected_files(prompt_bufnr) -- get selected files
    if #files == 0 then
        print("No files selected")
        return
    end
    local mark = require("harpoon.mark")
    for _, file in ipairs(files) do
        mark.add_file(file.filename)
    end
    if #files == 1 then
        local path = files[0] ~= nil and files[0].filename or files[1] ~= nil and files[1].filename or nil
        local message = path ~= nil and get_filename(path) or "1 file"
        print("Added " .. message .. " to harpoon")
    elseif #files > 1 then
        print("Added " .. #files .. " files to harpoon")
    end
end

local function create_and_add_to_harpoon()
    local path = fb_actions.create()
    if path ~= nil then
        require("harpoon.mark").add_file(path)
        print("Added " .. get_filename(path) .. " to harpoon")
    end
end

telescope.setup({
    extensions = {
        ["ui-select"] = {
            require("telescope.themes").get_dropdown({

            })
        },
        file_browser = {
            theme = "ivy",
            hijack_netrw = true,
            mappings = {
                ["i"] = {
                    ["<C-a>"] = add_selected_to_harpoon,
                    ["<C-n>"] = create_and_add_to_harpoon,
                },
                ["n"] = {
                    ["%"] = create_and_add_to_harpoon,
                    ["a"] = add_selected_to_harpoon,
                }
            }
        }
    }
})

telescope.load_extension("noice")
telescope.load_extension("ui-select")
telescope.load_extension("neoclip")
telescope.load_extension("harpoon")
telescope.load_extension("lsp_handlers")
telescope.load_extension("command_center")
telescope.load_extension("aerial")
telescope.load_extension("file_browser")

N_map('<leader>ff', builtin.find_files)
N_map('<C-p>', builtin.git_files)
N_map('<leader>fs', builtin.grep_string)
N_map("<leader>fb", builtin.buffers)
