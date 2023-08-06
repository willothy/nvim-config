local commands = {
  Capture = {
    function(args)
      local function max_length(list)
        local max = 0
        for _, v in ipairs(list) do
          if #v > max then max = #v end
        end
        return max
      end
      local result = vim.api.nvim_exec2(args.args, { output = true })
      if result.output then
        if args.bang then
          vim.fn.setreg("*", result.output)
          return
        end
        result = vim.split(result.output, "\n")
        local buf, win = vim.lsp.util.open_floating_preview(result, "", {
          focus = true,
          focusable = true,
          border = "rounded",
          wrap = true,
          width = math.min(
            60,
            vim.o.columns - 10,
            math.max(max_length(result), 10)
          ),
        })
        vim.api.nvim_set_current_win(win)
        vim.keymap.set("n", "q", function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
        end, { buffer = buf })
        vim.api.nvim_create_autocmd("BufLeave", {
          buffer = buf,
          once = true,
          callback = function()
            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_win_close(win, true)
            end
          end,
        })
      end
    end,
    desc = "Capture command output",
    nargs = "?",
    bang = true,
  },
  CurrentDirRTP = {
    function()
      local cwd = vim.fn.getcwd(-1)
      vim.opt.rtp:prepend(cwd)
    end,
    desc = "Add the cwd to vim's runtime path",
  },
  Browse = {
    function(args)
      local target
      if args and args["args"] then
        target = args["args"]
      else
        target = vim.fn.getcwd(-1)
      end
      require("telescope").extensions.file_browser.file_browser({ cwd = target })
    end,
    nargs = "?",
    desc = "Browse the provided directory or the current directory",
  },
  Reload = {
    function(args)
      local util = require("willothy.util.debug")
      if args and args["args"] ~= "" then
        util.reload(args["args"])
      else
        util.reload(util.current_mod())
      end
    end,
    nargs = "?",
    desc = "Reload the current module",
  },
  Bd = {
    function()
      require("bufdelete").bufdelete(0, true)
    end,
    desc = "Close the current buffer",
  },
  Bda = {
    function()
      local bufs = vim
        .iter(vim.fn.getbufinfo({ buflisted = 1 }))
        :map(function(buf)
          return buf.bufnr
        end)
        :totable()
      require("bufdelete").bufdelete(bufs, true)
    end,
    desc = "Close all buffers",
  },
  LuaAttach = {
    function()
      require("luapad").attach()
    end,
    desc = "Attach a Lua REPL to the current buffer",
  },
  LuaDetach = {
    function()
      require("luapad").detach()
    end,
    desc = "Detach the Lua REPL from the current buffer",
  },
  Scratch = {
    function(args)
      local f = vim.fn.tempname()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, f)
      vim.bo[buf].filetype = (args.args and (#args.args > 1)) and args.args[1]
        or "lua"
      vim.bo[buf].buftype = ""
      vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
      vim.api.nvim_buf_set_option(buf, "swapfile", false)
      vim.api.nvim_set_current_buf(buf)
    end,
    desc = "Open a scratch buffer",
  },
}

vim.iter(commands):each(function(name, cmd)
  vim.api.nvim_create_user_command(name, cmd[1], {
    buffer = cmd.buffer,
    nargs = cmd.nargs,
    bar = cmd.bar,
    bang = cmd.bang,
    complete = cmd.complete,
    force = cmd.force,
    preview = cmd.preview,
    desc = cmd.desc,
    range = cmd.range,
    count = cmd.count,
    addr = cmd.addr,
    register = cmd.register,
    keepscript = cmd.keepscript,
  })
end)
