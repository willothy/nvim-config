local function get_filename(path)
  local start, _ = path:find("[%w%s!-={-|]+[_%.].+")
  return path:sub(start, #path)
end

local function add_selected_to_harpoon(prompt_bufnr)
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

local function opt()
  return {
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown({}),
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
          },
        },
      },
      lsp_handlers = {
        code_action = {
          telescope = require("telescope.themes").get_dropdown({}),
        },
      },
    },
  }
end

local function config()
  local t = require("telescope")
  t.setup(opt())
  t.load_extension("file_browser")
  t.load_extension("ui-select")
  vim.defer_fn(function()
    t.load_extension("neoclip")
    -- t.load_extension("harpoon")
    -- t.load_extension("lsp_handlers")
    -- t.load_extension("aerial")
    t.load_extension("menufacture")
    -- t.load_extension("conventional_commits")
  end, 5000)
end

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {},
    lazy = false,
    config = config,
  },
  -- {
  --   "https://git.sr.ht/~havi/telescope-toggleterm.nvim",
  --   lazy = true,
  --   event = "TermOpen",
  --   dependencies = {
  --     "akinsho/toggleterm.nvim",
  --     "nvim-telescope/telescope.nvim",
  --     "nvim-lua/plenary.nvim",
  --   },
  -- },
  -- {
  --   "olacin/telescope-cc.nvim",
  --   lazy = true,
  --   cmd = "Telescope",
  -- },
  -- {
  --   "gbrlsnchs/telescope-lsp-handlers.nvim",
  --   lazy = true,
  --   event = "LspAttach",
  -- },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    lazy = true,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    lazy = true,
  },
  {
    "molecule-man/telescope-menufacture",
    lazy = true,
  },
}
