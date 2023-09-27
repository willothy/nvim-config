local tmp = vim.env.TMPDIR
  or vim.env.TEMPDIR
  or vim.env.TMP
  or vim.env.TEMP
  or "/tmp"
local data = tmp .. "/" .. (vim.env.NVIM_APPNAME or "nvim")
local packages_root = data .. "/site"
local cloned_root = packages_root .. "/pack/packages/start"

local plugins = {
  -- {
  --   "Bekaboo/dropbar.nvim",
  --   config = function()
  --     require("dropbar").setup()
  --   end,
  -- },
  -- {
  --   "willothy/nvim-cokeline",
  --   config = function()
  --     require("cokeline").setup()
  --   end,
  -- },
  -- {
  --   "willothy/flatten.nvim",
  --   config = function()
  --     require("flatten").setup()
  --   end
  -- }
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
