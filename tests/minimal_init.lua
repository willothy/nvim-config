local data_dir = vim.fn.stdpath("data")

local tests_dir = data_dir .. "/test_cache"

local dependencies = {
  "nvim-lua/plenary.nvim",
}

local download_semaphore = 0

vim.iter(dependencies):each(function(dep)
  if not vim.uv.fs_stat(tests_dir .. "/" .. dep:gsub(".*/", "")) then
    download_semaphore = download_semaphore + 1
    vim.system({
      "git",
      "clone",
      "git@github.com:" .. dep .. ".git",
      tests_dir .. "/" .. dep:gsub(".*/", ""),
    }, {}, function()
      download_semaphore = download_semaphore - 1
    end)
  end
  vim.opt.rtp:prepend(tests_dir .. "/" .. dep:gsub(".*/", ""))
end)

-- wait for up to 60 seconds for all dependencies to download
vim.wait(60000, function()
  return download_semaphore == 0
end, 200)

require("plenary.test_harness").test_directory(
  vim.fn.stdpath("config") .. "/tests"
)
