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
    function(args)
      local cwd = vim.fn.getcwd(-1)
      vim.opt.rtp:prepend(cwd)
    end,
    desc = "Add the cwd to vim's runtime path",
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
