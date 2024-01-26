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

vim.api.nvim_create_autocmd("BufEnter", {
  once = true,
  callback = function()
    pcall(vim.treesitter.start)
    vim.lsp.start({
      name = "lua_ls",
      cmd = { "lua-language-server" },
      root_dir = vim.fn.getcwd(),
      filetypes = { "lua" },
    })
  end,
})

local plugins = {
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
  {
    "willothy/wezterm.nvim",
    config = function()
      require("wezterm").setup({})
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup()
    end,
  },
  {
    "willothy/flatten.nvim",
    config = function()
      local saved_terminal

      require("flatten").setup({
        window = {
          open = "alternate",
        },
        callbacks = {
          should_block = function(argv)
            -- Note that argv contains all the parts of the CLI command, including
            -- Neovim's path, commands, options and files.
            -- See: :help v:argv

            -- In this case, we would block if we find the `-b` flag
            -- This allows you to use `nvim -b file1` instead of
            -- `nvim --cmd 'let g:flatten_wait=1' file1`
            return vim.tbl_contains(argv, "-b")

            -- Alternatively, we can block if we find the diff-mode option
            -- return vim.tbl_contains(argv, "-d")
          end,
          pre_open = function()
            local term = require("toggleterm.terminal")
            local termid = term.get_focused_id()
            saved_terminal = term.get(termid)
          end,
          post_open = function(bufnr, winnr, ft, is_blocking)
            if is_blocking and saved_terminal then
              -- Hide the terminal while it's blocking
              saved_terminal:close()
            else
              -- If it's a normal file, just switch to its window
              vim.api.nvim_set_current_win(winnr)

              -- If we're in a different wezterm pane/tab, switch to the current one
              -- Requires willothy/wezterm.nvim
              -- require("wezterm").switch_pane.id(
              --   tonumber(os.getenv("WEZTERM_PANE"))
              -- )
            end

            -- If the file is a git commit, create one-shot autocmd to delete its buffer on write
            -- If you just want the toggleable terminal integration, ignore this bit
            if ft == "gitcommit" or ft == "gitrebase" then
              vim.api.nvim_create_autocmd("QuitPre", {
                buffer = bufnr,
                once = true,
                callback = vim.schedule_wrap(function()
                  vim.cmd.split() -- create a new window (becuase the current one is closing from :q)
                  vim.cmd.bprev() -- it will have the same buffer, so :brev to go to the last one
                  vim.api.nvim_buf_delete(bufnr, {}) -- delete the buffer (so blocking ends)
                end),
              })
            end
          end,
          block_end = function()
            -- After blocking ends (for a git commit, etc), reopen the terminal
            vim.schedule(function()
              if saved_terminal then
                saved_terminal:open()
                saved_terminal = nil
              end
            end)
          end,
        },
      })
    end,
  },
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
