local function get_filename(path)
  local start, _ = path:find("[%w%s!-={-|]+[_%.].+")
  return path:sub(start, #path)
end

local function add_to_harpoon(prompt_bufnr)
  local fb_utils = require("telescope._extensions.file_browser.utils")
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
    local path = files[0] ~= nil and files[0].filename
      or files[1] ~= nil and files[1].filename
      or nil
    local message = path ~= nil and get_filename(path) or "1 file"
    print("Added " .. message .. " to harpoon")
  elseif #files > 1 then
    print("Added " .. #files .. " files to harpoon")
  end
end

local function create_and_add_to_harpoon(prompt_bufnr)
  local telescope = require("telescope")
  local fb_actions = telescope.extensions.file_browser.actions
  local path = fb_actions.create(prompt_bufnr)
  if path ~= nil then
    require("harpoon.mark").add_file(path)
    print("Added " .. get_filename(path) .. " to harpoon")
  end
end

local function edit(prompt_bufnr)
  require("telescope.actions.set").edit(prompt_bufnr, "stopinsert! | edit")
end

local function split(prompt_bufnr)
  require("telescope.actions.set").edit(prompt_bufnr, "stopinsert! | split")
end

local function vsplit(prompt_bufnr)
  require("telescope.actions.set").edit(prompt_bufnr, "stopinsert! | vsplit")
end

local function config()
  local t = require("telescope")
  t.setup({
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_cursor({}),
      },
      file_browser = {
        theme = "ivy",
        hijack_netrw = true,
        mappings = {
          ["i"] = {
            ["<C-a>"] = add_to_harpoon,
            ["<C-n>"] = create_and_add_to_harpoon,
            -- ["<CR>"] = edit,
            -- ["<C-v>"] = split,
            -- ["<C-h>"] = vsplit,
          },
          ["n"] = {
            ["c"] = create_and_add_to_harpoon,
            ["a"] = add_to_harpoon,
          },
        },
      },
      heading = {
        treesitter = true,
      },
    },
  })
  t.load_extension("file_browser")
  t.load_extension("ui-select")
  t.load_extension("menufacture")
  t.load_extension("projects")
  t.load_extension("noice")
  t.load_extension("macros")
  t.load_extension("scope")
  t.load_extension("yank_history")

  t.load_extension("heading")

  vim.api.nvim_create_autocmd("BufWinLeave", {
    callback = function(ev)
      if vim.bo[ev.buf].filetype == "TelescopePrompt" then
        vim.cmd("silent! stopinsert!")
      end
    end,
  })
end

return {
  {
    "nvim-telescope/telescope.nvim",
    config = config,
    cmd = "Telescope",
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
  },
  {
    "molecule-man/telescope-menufacture",
  },
  {
    "crispgm/telescope-heading.nvim",
  },
}
