local commands = {
  Detach = {
    function()
      vim.system({ "sesh", "detach" }, {}, function(obj)
        if obj.code ~= 0 then
          vim.notify("Failed to detach from session", vim.log.levels.ERROR, {})
        end
      end)
    end,
  },
  Capture = {
    function(args)
      local function max_length(list)
        local max = 0
        for _, v in ipairs(list) do
          if #v > max then
            max = #v
          end
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
          border = "solid",
          wrap = true,
          width = math.min(
            60,
            vim.o.columns - 10,
            math.max(max_length(result), 10)
          ),
        })
        vim.wo[win].winhl = "FloatBorder:NormalFloat"
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
  ReloadOnSave = {
    function(args)
      local mod = args.args

      local buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_create_autocmd("BufWritePost", {
        buffer = buf,
        callback = function()
          package.loaded[mod] = nil
          require(mod)
        end,
      })
    end,
    nargs = 1,
  },
  Reload = {
    function(args)
      local util = require("willothy.debug")
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
      if
        vim.api.nvim_buf_get_name(0) == ""
        and vim.api.nvim_buf_line_count(0) <= 1
        and vim.api.nvim_buf_get_lines(0, 0, -1, false)[1] == ""
      then
        vim.bo.buflisted = false
        vim.bo.bufhidden = "wipe"
        -- vim.bo.buftype = ""
      end
    end,
    desc = "Close the current buffer",
  },
  Bda = {
    function()
      local bufs = {}
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buflisted then
          table.insert(bufs, buf)
        end
      end
      require("bufdelete").bufdelete(bufs, true)
      if
        vim.api.nvim_buf_get_name(0) == ""
        and vim.api.nvim_buf_line_count(0) <= 1
        and vim.api.nvim_buf_get_lines(0, 0, -1, false)[1] == ""
      then
        vim.bo.buflisted = false
        vim.bo.bufhidden = "wipe"
        -- vim.bo.buftype = ""
      end
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
      local scratch = require("snacks").scratch
      if #args.fargs == 0 then
        scratch()
        return
      end
      local cmd = {
        list = function()
          scratch.list()
        end,
        select = function()
          scratch.select()
        end,
        open = function(open_args)
          local kv = {}
          for _, str in ipairs(open_args) do
            local k, v = str:match("([^=]+)=(.*)")
            kv[k] = v
          end

          scratch.open(kv)
        end,
      }
      cmd[args.fargs[1]]({ unpack(args.fargs, 2) })
    end,
    nargs = "*",
    desc = "Open a scratch buffer",
  },
  BrowserSwitch = {
    function()
      require("willothy.lib.fs").set_browser()
    end,
    desc = "Select a browser",
  },
  Sync = {
    function()
      require("lazy").sync()
    end,
    desc = "Update plugins",
  },
  Q = { "q", desc = ":q, common cmdline typo" },
  W = { "w", desc = ":w, common cmdline typo" },
  Color = {
    function()
      require("minty.huefy").open()
    end,
    desc = "Color picker",
  },
}

for name, cmd in pairs(commands) do
  local command = cmd[1]
  cmd[1] = nil
  vim.api.nvim_create_user_command(name, command, cmd)
end
