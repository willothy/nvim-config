vim.g.mapleader = " "

local tmp = vim.env.TMPDIR
  or vim.env.TEMPDIR
  or vim.env.TMP
  or vim.env.TEMP
  or "/tmp"
local data = tmp .. "/" .. (vim.env.NVIM_APPNAME or "nvim")
local packages_root = data .. "/site"
local cloned_root = packages_root .. "/pack/packages/start"

local data_dir = vim.fn.stdpath("data")
vim.env.PATH = vim.env.PATH .. ":" .. data_dir .. "/mason/bin"

-- vim.api.nvim_create_autocmd("BufEnter", {
--   once = true,
--   callback = function()
--     pcall(vim.treesitter.start)
--     vim.lsp.start({
--       name = "lua_ls",
--       cmd = { "lua-language-server" },
--       root_dir = vim.fn.getcwd(),
--       filetypes = { "lua" },
--     })
--   end,
-- })

local plugins = {
  {
    "folke/lazy.nvim",
    config = function()
      require("lazy").setup()
    end
  }
  -- {
  --   "Bekaboo/dropbar.nvim",
  --   config = function()
  --     require("dropbar").setup()
  --     vim.keymap.set("n", "<leader>b", require("dropbar.api").pick)
  --   end,
  -- },
  -- {
  --   "willothy/nvim-cokeline",
  --   config = function()
  --     require("cokeline").setup()
  --   end,
  -- },
}

-- setup package paths and clone plugins if necessary
for _, plugin in ipairs(plugins) do
  local owner, repo = plugin[1]:match("(.+)/(.+)")
  local cloned_path = cloned_root .. "/" .. repo
  local url = ("https://github.com/%s/%s.git"):format(owner, repo)

  vim.fn.mkdir(cloned_root, "p")
  vim.opt.pp:prepend(packages_root)
  vim.opt.rtp:prepend(packages_root)

  if not vim.loop.fs_stat(cloned_path) then
    vim.fn.system({ "git", "clone", url, cloned_path })
  end
end

-- setup all plugins
for _, plugin in ipairs(plugins) do
  if plugin.config then
    plugin.config()
  end
end
