---@type Terminal?
local saved_terminal

require("flatten").setup({
  window = {
    open = "smart",
  },
  nest_if_no_args = true,
  integrations = {
    wezterm = true,
  },
  callbacks = {
    pipe_path = function()
      -- If running in a terminal inside Neovim:
      local nvim = vim.env.NVIM
      if nvim then
        return nvim
      end

      -- If running in a Wezterm terminal,
      -- all tabs/windows/os-windows in the same instance of wezterm will open in the first neovim instance
      local wezterm = vim.env.WEZTERM_UNIX_SOCKET
      if not wezterm then
        return
      end

      local addr = ("%s/%s"):format(
        vim.fn.stdpath("run"),
        "wezterm.nvim-"
          .. wezterm:match("gui%-sock%-(%d+)")
          .. "-"
          .. vim.fn.getcwd(-1):gsub("/", "_")
      )
      if not vim.loop.fs_stat(addr) then
        vim.fn.serverstart(addr)
      end

      return addr
    end,
    should_block = function(argv)
      return vim.tbl_contains(argv, "-b")
    end,
    -- should_nest = function(argv)
    --   -- return vim.tbl_contains(argv, "-n")
    --   return false
    -- end,
    guest_data = function()
      return {
        pane = require("wezterm").get_current_pane(),
      }
    end,
    pre_open = function(_opts)
      local term = require("toggleterm.terminal")
      local id = term.get_focused_id()
      saved_terminal = term.get(id)
    end,
    no_files = function()
      -- If there's already a Neovim instance for this cwd, switch to it
      local wezterm = require("wezterm")

      local pane = wezterm.get_current_pane()
      if pane then
        require("wezterm").switch_pane.id(pane)
      end

      return {
        nest = false,
        block = false,
      }
    end,
    post_open = function(opts)
      local bufnr, winnr, ft, is_blocking, is_diff =
        opts.bufnr, opts.winnr, opts.filetype, opts.is_blocking, opts.is_diff

      if is_blocking and saved_terminal then
        -- Hide the terminal while it's blocking
        saved_terminal:close()
      elseif not is_diff then
        -- If it's a normal file, just switch to its window
        vim.api.nvim_set_current_win(winnr)

        -- If it's not in the current wezterm pane, switch to that pane.
        local wezterm = require("wezterm")

        local pane = wezterm.get_current_pane()
        if pane then
          require("wezterm").switch_pane.id(pane)
        end
      end

      -- If the file is a git commit, create one-shot autocmd to delete its buffer on write
      -- If you just want the toggleable terminal integration, ignore this bit
      if ft == "gitcommit" or ft == "gitrebase" then
        -- vim.schedule(vim.cmd.startinsert)
        vim.api.nvim_create_autocmd("BufWritePost", {
          buffer = bufnr,
          once = true,
          callback = vim.schedule_wrap(function()
            require("bufdelete").bufdelete(bufnr, true)
          end),
        })
      end
    end,
    -- After blocking ends (for a git commit, etc), reopen the terminal
    block_end = vim.schedule_wrap(function(opts)
      if type(opts.data) == "table" and opts.data.pane then
        require("wezterm").switch_pane.id(opts.data.pane)
      end
      if saved_terminal then
        saved_terminal:open()
        saved_terminal = nil
      end
    end),
  },
})
